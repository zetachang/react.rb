module React
  class State
    class << self
      attr_reader :current_observer

      def initialize_states(object, initial_values) # initialize objects' name/value pairs
        states[object].merge!(initial_values || {})
      end

      def get_state(object, name, current_observer = @current_observer)
        # get current value of name for object, remember that the current object depends on this state, current observer can be overriden with last param
        new_observers[current_observer][object] << name if current_observer and !new_observers[current_observer][object].include? name
        states[object][name]
      end

      def set_state2(object, name, value)  # set object's name state to value, tell all observers it has changed.  Observers must implement update_react_js_state
        observers_by_name[object][name].dup.each do |observer|
          observer.update_react_js_state(object, name, value)
        end
      end

      def set_state(object, name, value, delay=nil)
        states[object][name] = value
        if delay
          @delayed_updates ||= []
          @delayed_updates << [object, name, value]
          @delayed_updater ||= after(0.001) do
            delayed_updates = @delayed_updates
            @delayed_updates = []
            @delayed_updater = nil
            delayed_updates.each do |object, name, value|
              set_state2(object, name, value)
            end
          end
        else
          set_state2(object, name, value)
        end
        value
      end

      def will_be_observing?(object, name, current_observer)
        current_observer and new_observers[current_observer][object].include?(name)
      end

      def is_observing?(object, name, current_observer)
        current_observer and observers_by_name[object][name].include?(current_observer)
      end

      def update_states_to_observe(current_observer = @current_observer)  # should be called after the last after_render callback, currently called after components render method
        raise "update_states_to_observer called outside of watch block" unless current_observer
        current_observers[current_observer].each do |object, names|
          names.each do |name|
            observers_by_name[object][name].delete(current_observer)
          end
        end
        observers = current_observers[current_observer] = new_observers[current_observer]
        new_observers.delete(current_observer)
        observers.each do |object, names|
          names.each do |name|
            observers_by_name[object][name] << current_observer
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
        if `typeof window.reactive_ruby_timing !== 'undefined'`
          @nesting_level = (@nesting_level || 0) + 1
          start_time = Time.now.to_f
          observer_name = (observer.class.respond_to?(:name) ? observer.class.name : observer.to_s) rescue "object:#{observer.object_id}"
          puts "#{'  ' * @nesting_level} Timing #{observer_name} Execution"
        end
        saved_current_observer = @current_observer
        @current_observer = observer
        return_value = yield
        if `typeof window.reactive_ruby_timing !== 'undefined'`
          puts "#{'  ' * @nesting_level} Timing #{observer_name} Completed in #{'%.04f' % (Time.now.to_f-start_time)} seconds"
        end
        return_value
      ensure
        @current_observer = saved_current_observer
        @nesting_level = [0, @nesting_level - 1].max if `typeof window.reactive_ruby_timing !== 'undefined'`
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
