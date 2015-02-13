require "./ext/string"

module React
  class Element
    include Native
    
    alias_native :element_type, :type
    alias_native :props, :props
    
    def initialize(native_element)
      @native = native_element
    end
    
    def on(event_name)
      name = event_name.to_s.event_camelize
      if React::Event::BUILT_IN_EVENTS.include?("on#{name}")
        self.props["on#{name}"] = %x{ 
          function(event){
            #{yield React::Event.new(`event`)}
          }
        }
      else
        self.props["_on#{name}"] = %x{ 
          function(){
            #{yield *Array(`arguments`)}
          }
        }
      end
      self
    end
  end
end