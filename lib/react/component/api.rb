module React
  module Component
    module API
      def state
        Native(`#{self}.state`)
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
      
      #FIXME: Should be deprecated in favor of sth like, React.find_dom_node(component)
      def dom_node
        Native(`React.findDOMNode(#{self})`)
      end
    end
  end
end