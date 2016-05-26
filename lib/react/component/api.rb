module React
  module Component
    module API
      def dom_node
        if !(`typeof ReactDOM === 'undefined' || typeof ReactDOM.findDOMNode === 'undefined'`)
          `ReactDOM.findDOMNode(#{self}.native)` # v0.14.0
        elsif !(`typeof React.findDOMNode === 'undefined'`)
          `React.findDOMNode(#{self}.native)`    # v0.13.0
        else
          `#{self}.native.getDOMNode`            # v0.12.0
        end
      end

      def mounted?
        `#{self}.native.isMounted()`
      end

      def force_update!
        `#{self}.native.forceUpdate()`
      end

      def set_props(prop, &block)
        set_or_replace_state_or_prop(prop, 'setProps', &block)
      end

      def set_props!(prop, &block)
        set_or_replace_state_or_prop(prop, 'replaceProps', &block)
      end

      def set_state(state, &block)
        set_or_replace_state_or_prop(state, 'setState', &block)
      end

      def set_state!(state, &block)
        set_or_replace_state_or_prop(state, 'replaceState', &block)
      end

      private

      def set_or_replace_state_or_prop(state_or_prop, method, &block)
        raise "No native ReactComponent associated" unless @native
        %x{
          #{@native}[#{method}](#{state_or_prop.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end
    end
  end
end
