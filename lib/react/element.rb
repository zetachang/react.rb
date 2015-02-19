require "./ext/string"

module React
  class Element
    include Native

    alias_native :element_type, :type
    alias_native :props, :props

    def initialize(native_element)
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
