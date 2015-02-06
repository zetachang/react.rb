module React
  module Component          
    def self.included(base)
      @@before_mount_callbacks = {}
      @@after_mount_callbacks = {}
      base.extend(ClassMethods)
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
        
      end
    end
  end
end