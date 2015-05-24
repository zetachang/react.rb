require "react/ext/string"
require 'active_support/core_ext/class/attribute'
require 'react/callbacks'
require "react/ext/hash"
require "react/rendering_context"
require "react/observable"

module React
  module Component
    
    def self.included(base)
      base.include(API)
      base.include(React::Callbacks)
      base.class_eval do
        class_attribute :init_state
        define_callback :before_mount
        define_callback :after_mount
        define_callback :before_receive_props
        define_callback :before_update
        define_callback :after_update
        define_callback :before_unmount
      end
      base.extend(ClassMethods)
      
      parent = base.name.split("::").inject([Module]) { |nesting, next_const| nesting + [nesting.last.const_get(next_const)] }[-2]
      parent.class_eval do
        
        def method_missing(n, *args, &block)  
          unless name = const_get(n) and name.method_defined? :render
            return super
          end
          React::RenderingContext.render(name, *args, &block)
        end
        
      end
    end

    def initialize(native_element)
      @native = native_element
    end

    def params
      Hash.new(`#{@native}.props`)
    end

    def refs
      Hash.new(`#{@native}.refs`)
    end

    def state
      raise "No native ReactComponent associated" unless @native
      Hash.new(`#{@native}.state`)
    end

    def emit(event_name, *args)
      self.params["_on#{event_name.to_s.event_camelize}"].call(*args)
    end

    def component_will_mount
      self.run_callback(:before_mount)
    end

    def component_did_mount
      self.run_callback(:after_mount)
    end

    def component_will_receive_props(next_props)
      self.run_callback(:before_receive_props, Hash.new(next_props))
    end

    def should_component_update?(next_props, next_state)
      self.respond_to?(:needs_update?) ? self.needs_update?(Hash.new(next_props), Hash.new(next_state)) : true
    end

    def component_will_update(next_props, next_state)
      self.run_callback(:before_update, Hash.new(next_props), Hash.new(next_state))
    end

    def component_did_update(prev_props, prev_state)
      self.run_callback(:after_update, Hash.new(prev_props), Hash.new(prev_state))
    end

    def component_will_unmount
      self.run_callback(:before_unmount)
    end

    def p(*args, &block)
      if block || args.count == 0 || (args.count == 1 && args.first.is_a?(Hash))
        _p_tag(*args, &block)
      else
        Kernel.p(*args)
      end
    end
    
    def component?(name)
      name_list = name.split("::")
      scope_list = self.class.name.split("::").inject([Module]) { |nesting, next_const| nesting + [nesting.last.const_get(next_const)] }.reverse
      scope_list.each do |scope|
        component = name_list.inject(scope) do |scope, class_name| 
          scope.const_get(class_name)
        end rescue nil
        return component if component and component.method_defined? :render
      end
      nil
    end

    def method_missing(n, *args, &block)
      return params[n] if params.key? n
      name = n
      unless (React::HTML_TAGS.include?(name) || name == 'present' || name == '_p_tag' || (name = component?(name, self)))
        return super
      end

      if name == "present" 
        name = args.shift
      end

      if name == "_p_tag"
        name = "p"
      end

      React::RenderingContext.render(name, *args, &block)
    end
    
    def watch(value, &on_change)
      React::Observable.new(value, on_change)
    end
    
    def _render_debug_wrapper
      render
    rescue Exception => e
      puts "Exception raised while rendering #{self.class.name}: #{e}"
    end

    module ClassMethods
      
      def validator
        @validator ||= React::Validator.new
      end
      
      def prop_types
        if self.validator
          {
            _componentValidator: %x{
              function(props, propName, componentName) {
                var errors = #{validator.validate(Hash.new(`props`))};
                var error = new Error(#{"In component `" + self.name + "`\n" + `errors`.join("\n")});
                return #{`errors`.count > 0 ? `error` : `undefined`};
              }
            }
          }
        else
          {}
        end
      end

      def initial_state
        self.init_state || {}
      end

      def default_props
        validator.default_props
      end

      def params(&block)
        validator.build(&block)
      end
      
      def define_param_method(name, param_type)
        if param_type == React::Observable
          (@two_way_params ||= []) << name
          define_method("#{name}") do
            params[name].instance_variable_get("@value")
          end
          define_method("#{name}!") do |*args|
            if args.count > 0
              current_value = params[name].instance_variable_get("@value")
              params[name].call args[0]
              current_value
            else
              current_value = params[name].instance_variable_get("@value")
              params[name].call current_value unless @dont_update_state rescue nil # rescue in case we in middle of render
              params[name]
            end
          end
        elsif param_type == Proc
          define_method("#{name}") do |*args, &block|
            params[name].call *args, &block
          end
        else
          define_method("#{name}") do
            params[name]
          end
        end
      end
      
      def required_param(name, options = {})
        validator.requires(name, options)
        define_param_method(name, options[:type])
      end
      
      alias_method :require_param, :required_param
      
      def optional_param(name, options = {})
        validator.optional(name, options)
        define_param_method(name, options[:type])
      end 

      def define_state(*states)
        
        self.init_state ||= {} 
        default_initial_value = block_given? ? yield : nil
        states_hash = (states.last.is_a? Hash) ? states.pop : {}
        states.each { |name| states_hash[name] = default_initial_value }
        self.init_state.merge! states_hash
        states_hash.each do |name, initial_value|
          # getter
          define_method("#{name}") do
            return unless @native
            self.state.merge(@_react_component_current_state || {})[name]
          end
          # setter
          define_method("#{name}=") do |new_state|
            return unless @native
            hash = {}
            hash[name] = new_state
            @_react_component_current_state ||= {}
            @_react_component_current_state.merge!(hash)
            self.set_state(hash)
            new_state
          end
          # observable object
          define_method("#{name}!") do |*args|
            return unless @native
            if args.count > 0
              current_value = self.state[name]
              self.send("#{name}=", args[0])
              current_value
            else
              # dont_update_state is set in the top_level_component_class while mounting the components
              self.send("#{name}=", self.send("#{name}")) unless @dont_update_state rescue nil # rescue in case we in middle of render
              watch(self.state[name]) {|new_value| self.send("#{name}=", new_value)}
            end
          end
        end
      end
    end

    module API
      include Native

      alias_native :dom_node, :getDOMNode
      alias_native :mounted?, :isMounted
      alias_native :force_update!, :forceUpdate

      def set_props(prop, &block)
        raise "No native ReactComponent associated" unless @native
        %x{
          #{@native}.setProps(#{prop.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end

      def set_props!(prop, &block)
        raise "No native ReactComponent associated" unless @native
        %x{
          #{@native}.replaceProps(#{prop.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end

      def set_state(state, &block)
        raise "No native ReactComponent associated" unless @native
        %x{
          #{@native}.setState(#{state.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end

      def set_state!(state, &block)
        raise "No native ReactComponent associated" unless @native
        %x{
          #{@native}.replaceState(#{state.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end
    end
    
  end
end
