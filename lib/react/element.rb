require "./ext/string"

module React
  class Element < `(function(){var f = new Function();f.prototype = Object.getPrototypeOf(React.createElement(''));return f})()`
    def self.new
      raise "use React.create_element instead"
    end
    
    def element_type
      `self.type`
    end
    
    def key
      Native(`self.key`)
    end
    
    def props
      Hash.new(`self.props`)
    end
    
    def ref
      Native(`self.ref`)
    end
    
    def on(event_name)
      name = event_name.to_s.event_camelize
      
      
      if React::Event::BUILT_IN_EVENTS.include?("on#{name}")
        prop_key = "on#{name}"
        callback =  %x{
          function(event){
            #{yield React::Event.new(`event`)}
          }
        }
      else
        prop_key = "_on#{name}"
        callback = %x{
          function(){
            #{yield *Array(`arguments`)}
          }
        }
      end
      
      `self.props[#{prop_key}] = #{callback}`
      
      self
    end

    def children
      nodes = `self.props.children`
      
      if `React.Children.count(nodes)` == 0
        []
      elsif `React.Children.count(nodes)` == 1
        [`React.Children.only(nodes)`]
      else
        # Not sure the overhead of doing this..
        class << nodes
          include Enumerable

          def to_n
            self
          end

          def each(&block)
            if block_given?
              %x{
                React.Children.forEach(#{self.to_n}, function(context){
                  #{block.call(`context`)}
                })
              }
            else
              Enumerator.new(`React.Children.count(#{self.to_n})`) do |y|
                %x{
                  React.Children.forEach(#{self.to_n}, function(context){
                    #{y << `context`}
                  })
                }
              end
            end
          end
        end
        
        nodes
      end
    end
  
    def to_n
      self
    end
  end
end
