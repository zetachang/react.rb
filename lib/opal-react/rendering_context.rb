module React
  
  class RenderingContext
    
    def self.render(name, *args, &block)
      @buffer = [] unless @buffer
      if block
        element = build do
          result = block.call
          @buffer << result unless @buffer.count > 0 and @buffer.last == result
          React.create_element(name, *args) { @buffer }
        end
      else
        element = React.create_element(name, *args)
      end

      @buffer << element
      element
      
    end
    
    def self.build(&block)
      current = @buffer
      @buffer = []
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
    
    def span(*args)
      args.unshift('span')
      React::RenderingContext.render(*args) { self }
    end
    
    def br
      React::RenderingContext.render("span") { self.display; React::RenderingContext.render("br") }
    end
    
    def para(*args)
      args.unshift('para')
      React::RenderingContext.render(*args) { self }
    end
    
  end
  
end