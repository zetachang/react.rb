module React
  class Event
    include Native
    def initialize(native_element)
      @native = native_element
    end
  end
end