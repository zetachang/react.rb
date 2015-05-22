module React
  
  class Observable

    def initialize(value, on_change)
      @value = value
      @on_change = on_change 
    end

    def method_missing(method_sym, *args, &block)
      @value.send(method_sym, *args, &block).tap { |result| @on_change.call result}
    end

    def respond_to?(method, *args)
      if [:call, :to_proc].include? method
        true
      else
        @value.respond_to? method, *args
      end
    end
  
    def call(new_value)
      @on_change.call new_value
      @value = new_value
    end
    
    def to_proc
      lambda { |arg = @value| @on_change.call arg }
    end
  
  end
  
end