module React
  
  class Element
    
    attr_accessor :has_uncleared_loads
    
    def setup_while_loading(original_name, original_block)
      #puts "setup_while_loading(#{original_name}, #{original_block})"
      @has_uncleared_loads = true
      @original_name = original_name
      @original_block = original_block
    end
    
    def while_loading_show(opts={}, &block)
      #puts "while_loading_show: block: (#{!!block}) @original_name: (#{@original_name}) uncleared_loads: #{has_uncleared_loads}"
      return self unless has_uncleared_loads
      RenderingContext.delete(self) 
      #puts "should have deleted myself"
      @has_uncleared_loads = nil
      block ||= @original_block
      RenderingContext.render(@original_name, opts, &block).tap { |element| element.has_uncleared_loads = nil}
    end
    
    alias_method :show, :while_loading_show
    
  end
  
  class RenderingContext
    
    def self.push(element)
      @buffer << element
      element
    end
    
    def self.render(name, *args, &block)
      #puts "RenderingContext.render(#{name}, [#{args}], #{!!block})"
      @buffer = [] unless @buffer
      if block
        element = build do
          result = block.call
          
          if !name and (  # !name means called from outer render so we check that it has rendered correctly
              (@buffer.count > 1) or # should only render one element
              (@buffer.count == 1 and @buffer.last != result) or # it should return that element 
              (@buffer.count == 0 and !(result.is_a? String)) # for convience we will also convert the return value to a span if its a string
            )
            #puts "render result incorrect: name: #{name}, @buffer: [#{@buffer}], result: #{result}, result.is_a? String (#{result.is_a? String})"
            raise "a components render or while_loading method must generate and return exactly 1 element or a string"
          end
          @buffer.each { |ele| @last_element_loading_flag ||= ele.has_uncleared_loads  }
          @buffer << result.to_s if result.is_a? String # For convience we push the last return value on if its a string
          if name
            #puts "about to create a new element #{name}, [#{args}], { [#{@buffer}] } #{@buffer.last.class.name}"
            React.create_element(name, *args) { @buffer }
          elsif @buffer.last.is_a? React::Element
            @buffer.last
          else
            @buffer.last.to_s.span
          end
        end
      else
        element = React.create_element(name, *args)
      end
      element.setup_while_loading(name, block) if @last_element_loading_flag
      @buffer << element 
      @last_element_loading_flag = nil 
      element
    #ensure
    #  @last_element_loading_flag = nil 
    #  element
    end
    
    def self.build(&block)
      current = @buffer
      @buffer = []
      return_val = yield
      @buffer = current
      return_val
    #ensure
    #  @buffer = current
    #  return_val
    end
    
    def self.as_node(element)
      @buffer.delete(element)
      element
    end
    
    class << self; alias_method :delete, :as_node; end
    
    def self.element_loading!
      @last_element_loading_flag = true
    end
    
  end
  
  class ::String
    
    alias_method :old_display, :display
    
    def display(*args, &block)
      React::RenderingContext.render(self)
      old_display *args, &block if respond_to? :old_display
    end
    
    ["span", "para", "td", "th"].each do |tag|
      define_method(tag) do |*args|
        args.unshift(tag)
        React::RenderingContext.render(*args) { self }
      end
    end
    
    def br
      React::RenderingContext.render("span") { self.display; React::RenderingContext.render("br") }
    end
    
    
  end
  
end