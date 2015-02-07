module React
  class Element
    include Native
    
    alias_native :element_type, :type
    
    def initialize(native_element)
      @native = native_element
    end
  end
end