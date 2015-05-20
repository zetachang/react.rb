module React
  
  class Observable

    def initialize(value, on_change)
      @value = value
      @on_change = on_change 
    end
    
    attr_reader :value

    def method_missing(method_sym, *args, &block)
      @value.send(method_sym, *args, &block).tap { |result| @on_change.call result}
    end

    def respond_to?(method, *args)
      if method == :call
        true
      else
        @value.respond_to? method, *args
      end
    end
  
    def call(new_value)
      @on_change.call new_value
      @value = new_value
    end
  
  end
  
end