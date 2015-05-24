module React
  
  class RenderingContext
      
    def self.render(name, *args, &block)
      
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
    
  end
  
  class ::String
    
    alias_method :old_display, :display
    
    def display(*args, &block)
      React::RenderingContext.render(self)
      old_display *args, &block if respond_to? :old_display
    end
    
  end
  
end