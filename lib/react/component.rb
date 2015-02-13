require "./ext/string"

module React
  module Component            
    def self.included(base)
      @@before_mount_callbacks = {}
      @@after_mount_callbacks = {}
      @@init_state = {}
      
      base.class_eval do
        def self.class_attribute(*attrs)
          class << attrs 
            def extract_options!
              if last.is_a?(Hash) && last.extractable_options?
                pop
              else
                {}
              end
            end
          end

          options = attrs.extract_options!
          instance_reader = options.fetch(:instance_accessor, true) && options.fetch(:instance_reader, true)
          instance_writer = options.fetch(:instance_accessor, true) && options.fetch(:instance_writer, true)
          instance_predicate = options.fetch(:instance_predicate, true)

          attrs.each do |name|
            define_singleton_method(name) { nil }
            define_singleton_method("#{name}?") { !!public_send(name) } if instance_predicate

            ivar = "@#{name}"

            define_singleton_method("#{name}=") do |val|
              singleton_class.class_eval do
                #remove_possible_method(name)
                define_method(name) { val }
              end

              if true #singleton_class?
                class_eval do
                  #remove_possible_method(name)
                  define_method(name) do
                    if instance_variable_defined? ivar
                      instance_variable_get ivar
                    else
                      singleton_class.send name
                    end
                  end
                end
              end
              val
            end

            if instance_reader
              #remove_possible_method name
              define_method(name) do
                if instance_variable_defined?(ivar)
                  instance_variable_get ivar
                else
                  self.class.public_send name
                end
              end
              define_method("#{name}?") { !!public_send(name) } if instance_predicate
            end

            attr_writer name if instance_writer
          end
        end
      
        class_attribute :before_mount_callbacks, :after_mount_callbacks, :init_state
      end
      base.extend(ClassMethods)
    end
    
    def params
      Native(`#{@_bridge_object}.props`)
    end
    
    def refs
      Native(`#{@_bridge_object}.refs`)
    end
    
    def emit(event_name, *args)
      self.params["_on#{event_name.to_s.event_camelize}"].call(*args)
    end
    
    def _component_will_mount
      return unless self.class.before_mount_callbacks
      self.class.before_mount_callbacks.each do |callback|
        send(callback)
      end
    end
    
    def _component_did_mount
      return unless self.class.after_mount_callbacks
      self.class.after_mount_callbacks.each do |callback|
        send(callback)
      end
    end
    
    def _spec
      spec = %x{
        {
          componentWillMount: function() {
            #{@_bridge_object = `this`}
            #{self._component_will_mount()}
          },
          componentDidMount: function() {
            #{@_bridge_object = `this`}
            #{self._component_did_mount()}
          },
          render: function() {
            #{@_bridge_object = `this`}
            return #{self.render.to_n}
          }
        };
      }
      
      state = self.class.init_state
      
      %x{ 
        spec.getInitialState = function() {
          return #{state.to_n};
        }
      }
      
      return spec
    end
    
    module ClassMethods
      def before_mount(*callback)
        self.before_mount_callbacks=  callback
      end
      
      def after_mount(*callback)
        self.after_mount_callbacks = callback
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
            unless @_bridge_object
              self.class.init_state[name] 
            else
              `#{@_bridge_object}.state[#{name}]`
            end
          end
          # setter
          define_method("#{name}=") do |new_state|
            unless @_bridge_object
              self.class.init_state[name] = new_state
            else
              %x{
                state = #{@_bridge_object}.state || {};
                state[#{name}] = #{new_state};
                #{@_bridge_object}.setState(state);
              }
            end
            
            new_state
          end
        end
      end
    end
  end
end