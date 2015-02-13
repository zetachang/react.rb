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
      def camelize(string)
        `#{string}.replace(/(^|_)([^_]+)/g, function(match, pre, word, index) {
          var capitalize = true;
          return capitalize ? word.substr(0,1).toUpperCase()+word.substr(1) : word;
        })`
      end
      
      name = camelize(event_name.to_s)
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