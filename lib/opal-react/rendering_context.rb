module React
  
  class RenderingContext
    
    def initialize
      @buffer = []
    end
    
    def count
      @buffer.count
    end
    
    def <<(item)
      @buffer << item
    end
    
    def to_n
      @buffer.to_n
    end
    
    def self.render(name, *args, &block)
      @buffer = new unless @buffer
      if block
        element = build do
          result = block.call
          React.create_element(name, *args) { @buffer.count == 0 ? result : @buffer }
        end
      else
        element = React.create_element(name, *args)
      end

      @buffer << element
      element.attach(@buffer)
      element
      
    end
    
    def detach(element)
      @buffer.delete(element)
      element
    end
    
    def self.build(&block)
      current = @buffer
      @buffer = new
      return_val = yield
    ensure
      @buffer = current
      return_val
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