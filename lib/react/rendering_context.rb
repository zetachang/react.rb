module React
  class RenderingContext
    class << self
      attr_accessor :waiting_on_resources
    end

    def self.build_or_render(node_only, name, *args, &block)
      if node_only
        React::RenderingContext.build { React::RenderingContext.render(name, *args, &block) }.to_n
      else
        React::RenderingContext.render(name, *args, &block)
      end
    end

    def self.render(name, *args, &block)
      remove_nodes_from_args(args)
      @buffer = [] unless @buffer
      if block
        element = build do
          saved_waiting_on_resources = waiting_on_resources
          self.waiting_on_resources = nil
          result = block.call
          # Todo figure out how children rendering should happen, probably should have special method that pushes children into the buffer
          # i.e. render_child/render_children that takes Element/Array[Element] and does the push into the buffer
          if !name && (  # !name means called from outer render so we check that it has rendered correctly
              (@buffer.count > 1) || # should only render one element
              (@buffer.count == 1 && @buffer.last != result) || # it should return that element
              (@buffer.count == 0 && !(result.is_a?(String) || (result.respond_to?(:acts_as_string?) && result.acts_as_string?) || result.is_a?(Element))) #for convience we will also convert the return value to a span if its a string
            )
            raise "a components render method must generate and return exactly 1 element or a string"
          end

          @buffer << result.to_s if result.is_a? String || (result.respond_to?(:acts_as_string?) && result.acts_as_string?) # For convience we push the last return value on if its a string
          @buffer << result if result.is_a?(Element) && @buffer.count == 0
          if name
            buffer = @buffer.dup
            React.create_element(name, *args) { buffer }.tap do |element|
              element.waiting_on_resources = saved_waiting_on_resources || !!buffer.detect { |e| e.waiting_on_resources if e.respond_to?(:waiting_on_resources) }
            end
          elsif @buffer.last.is_a? React::Element
            @buffer.last.tap { |element| element.waiting_on_resources ||= saved_waiting_on_resources }
          else
            @buffer.last.to_s.span.tap { |element| element.waiting_on_resources = saved_waiting_on_resources }
          end
        end
      elsif name.is_a? React::Element
        element = name
        # I BELIEVE WAITING ON RESOURCES SHOULD ALREADY BE SET
      else
        element = React.create_element(name, *args)
        element.waiting_on_resources = waiting_on_resources
      end
      @buffer << element
      self.waiting_on_resources = nil
      element
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

    def self.remove_nodes_from_args(args)
      args[0].each do |key, value|
        value.as_node if value.is_a?(Element) rescue nil
      end if args[0] && args[0].is_a?(Hash)
    end
  end

  class ::Object
    alias_method :old_method_missing, :method_missing

    ["span", "para", "td", "th", "while_loading"].each do |tag|
      define_method(tag) do | *args, &block |
        args.unshift(tag)
        return self.method_missing(*args, &block) if self.is_a? React::Component
        React::RenderingContext.render(*args) { self.to_s }
      end
    end

    def para(*args, &block)
      args.unshift("p")
      return self.method_missing(*args, &block) if self.is_a? React::Component
      React::RenderingContext.render(*args) { self.to_s }
    end

    def br
      return self.method_missing(*["br"]) if self.is_a? React::Component
      React::RenderingContext.render("span") { React::RenderingContext.render(self.to_s); React::RenderingContext.render("br") }
    end
  end
end
