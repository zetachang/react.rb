module React
  class ElementBuilder
    def self.build(&block)
      self.new.instance_eval(&block)
    end
    
    def initialize
      @buffer = []
    end
    
    def method_missing(name, *args, &block)
      if name == "render"
        name = args.shift
      end
      
      if block
        current = @buffer
        @buffer = []
        block.call(self)
        element = React.create_element(name, *args) { @buffer }
        @buffer = current
      else        
        element = React.create_element(name, *args)
      end
      debugger
      @buffer << element
      element
    end
  end
end