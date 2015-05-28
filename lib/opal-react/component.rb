require "opal-react/ext/string"
require 'active_support/core_ext/class/attribute'
require 'opal-react/callbacks'
require "opal-react/ext/hash"
require "opal-react/rendering_context"
require "opal-react/observable"
require "opal-react/state"

require 'native'

module React
  module Component
    
    def self.included(base)
      base.include(API)
      base.include(React::Callbacks)
      base.class_eval do
        class_attribute :initial_state
        define_callback :before_mount
        define_callback :after_mount
        define_callback :before_receive_props
        define_callback :before_update
        define_callback :after_update
        define_callback :before_unmount
        
        def render
          raise "no render defined"
        end unless method_defined? :render
        
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
    
    def update_react_js_state(object, name, value)
      set_state({"#{object.class.to_s+'.' unless object == self}name" => value}) rescue nil # in case we are in render
    end

    def emit(event_name, *args)
      self.params["_on#{event_name.to_s.event_camelize}"].call(*args)
    end

    def component_will_mount
      React::State.initialize_states(self, initial_state)
      React::State.set_state_context_to(self) { self.run_callback(:before_mount) }
    end

    def component_did_mount
      React::State.set_state_context_to(self) { self.run_callback(:after_mount) }
    end

    def component_will_receive_props(next_props)
      React::State.set_state_context_to(self) { self.run_callback(:before_receive_props, Hash.new(next_props)) }
    end

    def should_component_update?(next_props, next_state)
      React::State.set_state_context_to(self) { self.respond_to?(:needs_update?) ? self.needs_update?(Hash.new(next_props), Hash.new(next_state)) : true }
    end

    def component_will_update(next_props, next_state)
      React::State.set_state_context_to(self) { self.run_callback(:before_update, Hash.new(next_props), Hash.new(next_state)) }
    end

    def component_did_update(prev_props, prev_state)
      React::State.set_state_context_to(self) do
        self.run_callback(:after_update, Hash.new(prev_props), Hash.new(prev_state))
      end
    end

    def component_will_unmount
      React::State.set_state_context_to(self) do 
        self.run_callback(:before_unmount)
        React::State.remove
      end
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
    
    def _render_wrapper
      React::State.set_state_context_to(self) do
        render_result = render
        React::State.update_states_to_observe
        render_result
      end
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
        default_initial_value = block_given? ? yield : nil
        states_hash = (states.last.is_a? Hash) ? states.pop : {}
        states.each { |name| states_hash[name] = default_initial_value }
        (self.initial_state ||= {}).merge! states_hash
        states_hash.each do |name, initial_value|
          define_state_methods(self, name)
        end
      end
      
      def export_state(*states) 
        default_initial_value = block_given? ? yield : nil
        states_hash = (states.last.is_a? Hash) ? states.pop : {}
        states.each { |name| states_hash[name] = default_initial_value }
        React::State.initialize_states(self, states_hash)
        states_hash.each do |name, initial_value|
          define_state_methods(self, name, self)
          define_state_methods(singleton_class, name, self)
        end
      end
      
      def define_state_methods(this, name, from = nil)
        this.define_method("#{name}") do
          React::State.get_state(from || self, name)
        end
        this.define_method("#{name}=") do |new_state|
          React::State.set_state(from || self, name, new_state)
        end
        this.define_method("#{name}!") do |*args|
          #return unless @native
          if args.count > 0
            current_value = React::State.get_state(from || self, name)
            React::State.set_state(from || self, name, args[0])
            current_value
          else
            current_state = React::State.get_state(from || self, name)
            React::State.set_state(from || self, name, current_state)
            React::Observable.new(current_state) {|new_value| React::State.set_state(from || self, name, new_value)}
            #watch(current_state) {|new_value| React::State.set_state(from || self, name, new_value)}
          end
        end
      end
      
      def export_component(opts = {})
        export_name = (opts[:as] || name).split("::")
        Native(`window`)[export_name.first] = ([React::API.create_native_react_class(self)] + export_name[1..-1].reverse).inject do |memo, sub_name| 
          {sub_name => memo}.to_n
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
