require "react/ext/string"
require 'active_support/core_ext/class/attribute'
require 'react/callbacks'
require "react/ext/hash"

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

    def method_missing(name, *args, &block)
      unless (React::HTML_TAGS.include?(name) || name == 'present' || name == '_p_tag' || (name = React.component?(name)))
        return super
      end

      if name == "present"
        name = args.shift
      end

      if name == "_p_tag"
        name = "p"
      end

      @buffer = [] unless @buffer
      if block
        current = @buffer
        @buffer = []
        result = block.call
        element = React.create_element(name, *args) { @buffer.count == 0 ? result : @buffer }
        @buffer = current
      else
        element = React.create_element(name, *args)
      end

      @buffer << element
      element
    end


    module ClassMethods
      
      class AutoCallBack

        def initialize(object, action)
          @object = object
          @action = action
        end

        def method_missing(method_sym, *arguments, &block)
          @action.call @object.send(method_sym, *arguments, &block)
          self
        end

        def respond_to?(*args)
          @object.respond_to? *args
        end

      end
      
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
        if param_type == Proc
          define_method("#{name}") do |*args, &block|
            params[name].call *args, &block
          end
        else
          define_method("#{name}") do
            params[name]
          end
        end
      end
      
      def require_param(name, options = {})
        validator.requires(name, options)
        define_param_method(name, options[:type])
      end
      
      def optional_param(name, options = {})
        validator.optional(name, options)
        define_param_method(name, options[:type])
      end    

      def define_state(*states)
        raise "Block could be only given when define exactly one state" if block_given? && states.count > 1

        self.init_state = {} unless self.init_state

        if block_given?
          self.init_state[states[0]] = yield
        end
        states.each do |name|
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
            self.set_state(hash)
            @_react_component_current_state ||= {}
            @_react_component_current_state.merge!(hash)
            new_state
          end
          # use my_state! when side effects are expected.  my_state! << 12 << 13 for example
          # or use my_state! x to update value instead of saying self.my_state = x
          define_method("#{name}!") do |*args|
            return unless @native
            if args.count > 0
              current_value = self.state[name]
              self.send("#{name}=", args[0])
              current_value
            else
              self.send("#{name}=", self.send("#{name}"))
              AutoCallBack.new(self.state[name], lambda { |updated_value| self.send("#{name}=", updated_value)})
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
    
    class Base
      include Component
    end
    
  end
end
