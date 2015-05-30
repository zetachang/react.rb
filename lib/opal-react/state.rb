module React
  
  class State
    
    class << self
      
      def initialize_states(object, initial_values) # initialize objects' name/value pairs
        states[object].merge!(initial_values || {})
      end

      def get_state(object, name) # get current value of name for object, remember that the current object depends on this state
        new_observers[@current_observer][object] << name if @current_observer and !new_observers[@current_observer][object].include? name
        states[object][name]
      end

      def set_state(object, name, value)  # set object's name state to value, tell all observers it has changed.  Observers must implement update_react_js_state
        states[object][name] = value
        observers_by_name[object][name].dup.each do |observer|
          observer.update_react_js_state(object, name, value)
        end
        value
      end

      def update_states_to_observe  # called after the last after_render callback
        raise "update_states_to_observer called outside of watch block" unless @current_observer
        current_observers[@current_observer].each do |object, names|
          names.each do |name| 
            observers_by_name[object][name].delete(@current_observer)
          end
        end
        observers = current_observers[@current_observer] = new_observers[@current_observer]
        new_observers.delete(@current_observer)
        observers.each do |object, names|
          names.each do |name|
            observers_by_name[object][name] << @current_observer
          end
        end
      end
      
      def remove # call after component is unmounted
        raise "remove called outside of watch block" unless @current_observer
        current_observers[@current_observer].each do |object, names|
          names.each do |name| 
            observers_by_name[object][name].delete(@current_observer)
          end
        end
        current_observers.delete(@current_observer)
      end

      def set_state_context_to(observer) # wrap all execution that may set or get states in a block so we know which observer is executing
        saved_current_observer = @current_observer
        @current_observer = observer
        return_value = yield
      ensure
        @current_observer = saved_current_observer
        return_value
      end
      
      def states
        @states ||= Hash.new { |h, k| h[k] = {} } 
      end
      
      def new_observers
        @new_observers ||= Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
      end
      
      def current_observers
        @current_observers ||= Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
      end
      
      def observers_by_name
        @observers_by_name ||= Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = [] } }
      end
      
    end
    
  end
  
end