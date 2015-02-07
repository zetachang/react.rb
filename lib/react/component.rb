module React
  module Component          
    def self.included(base)
      @@before_mount_callbacks = {}
      @@after_mount_callbacks = {}
      @@init_state = {}
      base.extend(ClassMethods)
    end
    
    def params
      Native(`#{@_bridge_object}.props`)
    end
    
    def _bridge_object=(object)
      @_bridge_object = object
    end
    
    def _init_state
      @@init_state[self.class.name]
    end
    
    def _component_will_mount
      return unless @@before_mount_callbacks[self.class.name]
      @@before_mount_callbacks[self.class.name].each do |callback|
        send(callback)
      end
    end
    
    def _component_did_mount
      return unless @@after_mount_callbacks[self.class.name]
      @@after_mount_callbacks[self.class.name].each do |callback|
        send(callback)
      end
    end
    
    module ClassMethods
      def before_mount(*callback)
        @@before_mount_callbacks[self.name] = callback
      end
      
      def after_mount(*callback)
        @@after_mount_callbacks[self.name] = callback
      end
      
      def define_state(*states)
        raise "Block could be only given when define exactly one state" if block_given? && states.count > 1      
        if block_given?
          @@init_state[self.name] = {} unless @@init_state[self.name]
          @@init_state[self.name][states[0]] = yield
        end
        states.each do |name|
          # getter
          define_method("#{name}") do
            state = Native(`#{@_bridge_object}.state`)
            state[name]
          end
          # setter
          define_method("#{name}=") do |new_state|
            state = Native(`#{@_bridge_object}.state`)
            state = {} unless state
            state[name] = new_state
            `#{@_bridge_object}.setState(#{state.to_n})`
            new_state
          end
        end
      end
    end
  end
end