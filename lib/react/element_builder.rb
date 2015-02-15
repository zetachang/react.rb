module React
  class ElementBuilder
    def self.build(proxy, &block)
      self.new(proxy).instance_eval(&block)
    end
    
    def initialize(proxy)
      @buffer = []
      @proxy = proxy
    end
    
    def method_missing(name, *args, &block)
      unless (React::HTML_TAGS.include?(name) || name == 'render')
        return @proxy.send(name, *args, &block)
      end
      
      if name == "render"
        name = args.shift
      end 
      
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
end