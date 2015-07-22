require "opal-react/ext/string"

module React
  class Element
    include Native

    alias_native :element_type, :type
    alias_native :props, :props
    
    attr_reader :type
    attr_reader :properties
    attr_reader :block
    
    attr_accessor :waiting_on_resources

    def initialize(native_element, type, properties, block)
      @type = type
      @properties = properties
      @block = block
      @native = native_element
    end

    def on(event_name)
      name = event_name.to_s.event_camelize
      if React::Event::BUILT_IN_EVENTS.include?("on#{name}")
        self.props["on#{name}"] = %x{
          function(event){
            #{yield React::Event.new(`event`)}
          }
        }
      else
        self.props["_on#{name}"] = %x{
          function(){
            #{yield *Array(`arguments`)}
          }
        }
      end
      self
    end
    
    def method_missing(class_name, args = {}, &new_block)
      new_props = properties.dup
      new_props["class"] = "#{new_props['class']} #{class_name} #{args['class']} #{args['className']}".split(" ").uniq.join(" ")
      RenderingContext.replace(
        self,
        React::RenderingContext.build { React::RenderingContext.render(type, new_props, &new_block) }
      )
    end
    
    def delete
      RenderingContext.delete(self)
    end

    def children
      nodes = self.props.children
      class << nodes
        include Enumerable

        def to_n
          self
        end

        def each(&block)
          if block_given?
            %x{
              React.Children.forEach(#{self.to_n}, function(context){
                #{block.call(React::Element.new(`context`))}
              })
            }
          else
            Enumerator.new(`React.Children.count(#{self.to_n})`) do |y|
              %x{
                React.Children.forEach(#{self.to_n}, function(context){
                  #{y << React::Element.new(`context`)}
                })
              }
            end
          end
        end
      end

      nodes
    end
  end
end
