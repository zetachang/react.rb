require 'opal-react/component'
#require 'opal-jquery'

module React
  
  class TopLevelComponent
    
    include Component
    
    def self.mount_component(component_class, mount_point, static_init = {}, &init)
      
      unless @components_to_mount 
        @components_to_mount = []
        top_level_component_class = Module.const_get(self.name)
        Document.ready.then do
          begin
          React.render(React.create_element(top_level_component_class), ::Element['<div></div>'])
          puts "should be rendered"
        rescue Exception => e
        puts e
      end
        end
      end
      
      @components_to_mount << {component_class: component_class, mount_point: mount_point, static_init: static_init, init: init}

    end
    
    def self.external_update(name, &block)
      define_singleton_method name do |*args|
        instance_ready? { |instance| State.set_state_context_to(instance) { instance.instance_exec *args, &block } }
      end
    end
    
    def self.instance_ready?
      @instance_ready = instance_ready.then { |instance| yield instance; instance}
    end
    
    def self.instance_ready
      @instance_ready ||= Promise.new
    end
    
    def instance_ready!
      self.class.instance_ready.resolve(self) unless self.class.instance_ready.resolved?
    end
        
    def self.components_to_mount
      @components_to_mount
    end
    
    def mount_components
      puts "mounting components now #{self}"
      State.set_state_context_to(self) do
        self.class.components_to_mount.each do |mount|
          init = mount[:static_init]
          if mount[:init]
            @dont_update_state = true
            begin
              init = init.merge(instance_eval &mount[:init]) 
            ensure
              @dont_update_state = nil
            end
          end
          #React.render(React.create_element(mount[:component_class], init), ::Element[mount[:mount_point]])
        end
        State.update_states_to_observe
        instance_ready!
      end
    rescue Exception => e
      puts e
    end
    
    after_mount  :mount_components
    after_update :mount_components
    
    def render 
    end
      
  end
  
end