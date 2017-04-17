module React
  
  class Observable
    
    # This is an internal class that is used to add other higher level features to state, and params

    def initialize(value, on_change = nil, &block)
      @value = value
      @on_change = on_change || block
    end

    def method_missing(method_sym, *args, &block)
      @value.send(method_sym, *args, &block).tap { |result| @on_change.call result }
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