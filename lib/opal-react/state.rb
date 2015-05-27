module React
  
  class State
    
    class << self
      
      def initialize_states(object, initial_values) # initialize objects, name/value pairs
        states[object].merge!(initial_values || {})
        puts "states initialized for #{object}: #{states[object]}"
      end

      def get_state(object, name) # get current value of name for object, remember that the current object depends on this state
        new_observers[@current_observer][object] << name if @current_observer and !new_observers[@current_observer][object].include? name
        puts "get_state(#{object}, #{name}) = #{states[object][name]}"
        states[object][name]
      rescue Exception => e
        puts "get state failed: #{e}"
      end

      def set_state(object, name, value)  # set object's name state to value, tell all observers it has changed.  Observers must implement update_react_js_state
        states[object][name] = value
        puts "set_state(#{object}, #{name}, #{value}). observers_by_name[#{object}][#{name}]: #{observers_by_name[object][name]}"
        observers = observers_by_name[object][name].dup
        observers_by_name[object][name].dup.each do |observer|
          puts "#{observer}.update_react_js_state(#{object}, #{name}, #{value})"
          observer.update_react_js_state(object, name, value)
          puts "after update getting next guy" #{}", observers = #{observers}"
        end
        puts "all done getting guys observers_by_name[#{object}][#{name}]: #{observers_by_name[object][name]}"
        value
      rescue Exception => e
        puts "set state failed: #{e}"
      end

      def update_states_to_observe  # called after the last after_render callback
        raise "update_states_to_observer called outside of watch block" unless @current_observer
        puts "#{@current_observer}.updating states to observe. new_observers: #{new_observers[@current_observer]}"
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
      rescue Exception => e
        puts "update_states_to_observe failed: #{e}"
      end
      
      def remove # call after component is unmounted
        raise "remove called outside of watch block" unless @current_observer
        current_observers[@current_observer].each do |object, names|
          names.each do |name| 
            observers_by_name[object][name].delete(@current_observer)
          end
        end
        current_observers.delete(@current_observer)
        new_observer.delete(@current_observer)
      end

      def set_state_context_to(observer) # wrap all execution that may set or get states in a block so we know which observer is executing
        puts "set_state_context_to(#{observer})"
        saved_current_observer = @current_observer
        @current_observer = observer
        return_value = yield
      rescue Exception => e
        puts e
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