module React
  module Component
    module API
      def state
        Hash.new(`#{self}.state`)
      end
      
      def props
        Hash.new(`#{self}.props`)
      end
      
      def force_update!
        `#{self}.forceUpdate()`
      end

      def set_state(state, &block)
        %x{
          #{self}.setState(#{state.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end
            
      def refs
        hash = {}
        
        %x{
          var refs = self.refs;
          for (var property in refs) {
            if (refs.hasOwnProperty(property)) {
              #{hash[`property`] = `refs[property]`}
            }
          }
        }

        hash
      end
      
      def dom_node
        raise "`dom_node` is deprecated in favor of `React.find_dom_node`"
      end
    end
  end
end
