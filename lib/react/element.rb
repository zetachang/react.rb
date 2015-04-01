require "./ext/string"

module React
  class Element < `OpalReactElement`    
    def self.new(native_element)
      native_element
    end
    
    def to_n
      self
    end
    
    def props
      Hash.new(`#{self}.props`)
    end
    
    def element_type
      `#{self}.type`
    end
    
    def key
      `#{self}.key`
    end

    def on(event_name)
      name = event_name.to_s.event_camelize
      if React::Event::BUILT_IN_EVENTS.include?("on#{name}")
        prop_name = "on#{name}"
        callback = %x{
          function(event){
            #{yield React::Event.new(`event`)}
          }
        }
      else
        prop_name = "_on#{name}"
        callback = %x{
          function(){
            #{yield *Array(`arguments`)}
          }
        }
      end
      new_props = `{}`    
      `new_props[#{prop_name}] = #{callback}`
      `new_props.ref = #{self}.ref`

      element = `React.addons.cloneWithProps(#{self}, new_props)`

      element
    end

    def children
      nodes = self.props[:children]
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
