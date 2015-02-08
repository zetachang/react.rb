require "active_support"

module React
  class Element
    include Native
    
    alias_native :element_type, :type
    alias_native :props, :props
    
    def initialize(native_element)
      @native = native_element
    end
    
    def on(event_name)
      name = event_name.to_s.camelize
      self.props["on#{name}"] = %x{ 
        function(event){
          #{yield React::Event.new(`event`)}
        }
      }
      self
    end
  end
end