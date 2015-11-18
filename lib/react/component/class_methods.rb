module React
  module Component
    module ClassMethods
      def backtrace(*args)
        @backtrace_off = (args[0] == :off)
      end

      def process_exception(e, component, reraise = nil)
        message = ["Exception raised while rendering #{component}"]
        if e.backtrace and e.backtrace.length > 1 and !@backtrace_off  # seems like e.backtrace is empty in safari???
          message << "    #{e.backtrace[0]}"
          message += e.backtrace[1..-1].collect { |line| line }
        else
          message[0] += ": #{e.message}"
        end
        message = message.join("\n")
        `console.error(message)`
        raise e if reraise
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
            params[name].instance_variable_get("@value") if params[name]
          end
          define_method("#{name}!") do |*args|
            return unless params[name]
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
            params[name].call(*args, &block) if params[name]
          end
        else
          define_method("#{name}") do
            @processed_params[name] ||= if param_type.respond_to? :_react_param_conversion
                                          param_type._react_param_conversion params[name]
                                        elsif param_type.is_a? Array and param_type[0].respond_to? :_react_param_conversion
                                          params[name].collect { |param| param_type[0]._react_param_conversion param }
                                        else
                                          params[name]
                                        end
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
        define_param_method(name, options[:type]) unless name == :params
      end

      def collect_other_params_as(name)
        validator.allow_undefined_props = true
        define_method(name) do
          @_all_others ||= self.class.validator.undefined_props(props)
        end
      end

      def define_state(*states, &block)
        default_initial_value = (block and block.arity == 0) ? yield : nil
        states_hash = (states.last.is_a? Hash) ? states.pop : {}
        states.each { |name| states_hash[name] = default_initial_value }
        (self.initial_state ||= {}).merge! states_hash
        states_hash.each do |name, initial_value|
          define_state_methods(self, name, &block)
        end
      end

      def export_state(*states, &block)
        default_initial_value = (block and block.arity == 0) ? yield : nil
        states_hash = (states.last.is_a? Hash) ? states.pop : {}
        states.each { |name| states_hash[name] = default_initial_value }
        React::State.initialize_states(self, states_hash)
        states_hash.each do |name, initial_value|
          define_state_methods(self, name, self, &block)
          define_state_methods(singleton_class, name, self, &block)
        end
      end

      def define_state_methods(this, name, from = nil, &block)
        this.define_method("#{name}") do
          React::State.get_state(from || self, name)
        end
        this.define_method("#{name}=") do |new_state|
          yield name, React::State.get_state(from || self, name), new_state if block and block.arity > 0
          React::State.set_state(from || self, name, new_state)
        end
        this.define_method("#{name}!") do |*args|
          #return unless @native
          if args.count > 0
            yield name, React::State.get_state(from || self, name), args[0] if block and block.arity > 0
            current_value = React::State.get_state(from || self, name)
            React::State.set_state(from || self, name, args[0])
            current_value
          else
            current_state = React::State.get_state(from || self, name)
            yield name, React::State.get_state(from || self, name), current_state if block and block.arity > 0
            React::State.set_state(from || self, name, current_state)
            React::Observable.new(current_state) do |update|
              yield name, React::State.get_state(from || self, name), update if block and block.arity > 0
              React::State.set_state(from || self, name, update)
            end
          end
        end
      end

      def native_mixin(item)
        native_mixins << item
      end

      def native_mixins
        @native_mixins ||= []
      end

      def static_call_back(name, &block)
        static_call_backs[name] = block
      end

      def static_call_backs
        @static_call_backs ||= {}
      end

      def export_component(opts = {})
        export_name = (opts[:as] || name).split("::")
        first_name = export_name.first
        Native(`window`)[first_name] = add_item_to_tree(Native(`window`)[first_name], [React::API.create_native_react_class(self)] + export_name[1..-1].reverse).to_n
      end

      def add_item_to_tree(current_tree, new_item)
        if Native(current_tree).class != Native::Object or new_item.length == 1
          new_item.inject do |memo, sub_name| {sub_name => memo} end
        else
          Native(current_tree)[new_item.last] = add_item_to_tree(Native(current_tree)[new_item.last], new_item[0..-2])
          current_tree
        end
      end
    end
  end
end
