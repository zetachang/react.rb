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
        raise "No native ReactComponent associated" unless @native
        %x{
          #{self}.setState(#{state.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end

      def set_state!(state, &block)
        raise "No native ReactComponent associated" unless @native
        %x{
          #{self}.replaceState(#{state.shallow_to_n}, function(){
            #{block.call if block}
          });
        }
      end
    end
  end
end