module React
  
  class RenderingContext
    
    class << self
      attr_accessor :waiting_on_resources
    end
    
    def self.render(name, *args, &block)
      #puts "RenderingContext.render(#{name}, [#{args}], #{!!block}), (#{waiting_on_resources})"
      @buffer = [] unless @buffer
      if block
        element = build do
          saved_waiting_on_resources = waiting_on_resources
          self.waiting_on_resources = nil
          result = block.call
          # Todo figure out how children rendering should happen, probably should have special method that pushes children into the buffer
          # i.e. render_child/render_children that takes Element/Array[Element] and does the push into the buffer
          if !name and (  # !name means called from outer render so we check that it has rendered correctly
              (@buffer.count > 1) or # should only render one element
              (@buffer.count == 1 and @buffer.last != result) or # it should return that element 
              (@buffer.count == 0 and !(result.is_a? String or result.is_a? Element)) #for convience we will also convert the return value to a span if its a string
            )
            #puts "render result incorrect: name: #{name}, @buffer: [#{@buffer}], result: #{result}, result.is_a? String (#{result.is_a? String})"
            raise "a components render method must generate and return exactly 1 element or a string"
          end
          
          @buffer << result.to_s if result.is_a? String # For convience we push the last return value on if its a string
          @buffer << result if result.is_a? Element and @buffer.count == 0
          if name
            #puts "about to create a new element #{name}, [#{args}], { [#{@buffer}] } #{@buffer.last.class.name}"
            buffer = @buffer.dup
            React.create_element(name, *args) { buffer }.tap do |element| 
              element.waiting_on_resources = saved_waiting_on_resources || !!buffer.detect { |e| e.waiting_on_resources if e.respond_to? :waiting_on_resources }
              #puts "1 #{element}.waiting_on_resources set to #{element.waiting_on_resources}"
            end
          elsif @buffer.last.is_a? React::Element
            @buffer.last.tap { |element| 
              #puts "2 #{element}.waiting_on_resources is = #{element.waiting_on_resources}"
              element.waiting_on_resources ||= saved_waiting_on_resources
              #puts "2 #{element}.waiting_on_resources set to #{element.waiting_on_resources}" 
              }
          else
            @buffer.last.to_s.span.tap { |element| 
              element.waiting_on_resources = saved_waiting_on_resources 
              #puts "3 #{element}.waiting_on_resources set to #{element.waiting_on_resources}"
              }
          end
        end
      else
        element = React.create_element(name, *args)
        element.waiting_on_resources = waiting_on_resources
        #puts "4 #{element}.waiting_on_resources set to #{element.waiting_on_resources}"
      end
      @buffer << element 
      self.waiting_on_resources = nil
      #puts "CLEARED WAITING ON RESOURCES"
      element
      #puts "HEY !!!!!!!!!!!! this is why it aint clearng #{e}"
    #ensure
    #  waiting_on_resources = nil 
    #  element
    end
    
    def self.build(&block)
      current = @buffer
      @buffer = []
      return_val = yield @buffer
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
    
    def self.replace(e1, e2)
      @buffer[@buffer.index(e1)] = e2 
    end
    
  end
 
  class ::Object
    
    alias_method :old_method_missing, :method_missing
    
    ["span", "para", "td", "th", "while_loading"].each do |tag|
      define_method(tag) do | *args |
        args.unshift(tag)
        React::RenderingContext.render(*args) { self.to_s }
      end
    end
    
    def br
      React::RenderingContext.render("span") { React::RenderingContext.render(self.to_s); React::RenderingContext.render("br") }
    end
    
  end

end