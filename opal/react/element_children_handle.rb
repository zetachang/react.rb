require "react/element"

module React
  class ElementChildrenHandle
    def initialize(children, index)
      @children = children
      @index = index
    end
    
    def on(event_name, &block) 
      old_element = @children[@index]
      new_element = React::Element.attach_event_callback(old_element, event_name, &block)
      @children[@index] = new_element
      self
    end
  end
end
