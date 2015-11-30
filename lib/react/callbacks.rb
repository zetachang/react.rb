require 'active_support/core_ext/class/attribute'

module React
  module Callbacks
    def self.included(base)
      base.extend(ClassMethods)
    end

    def run_callback(name, *args)
      self.class.callbacks_for(name).each do |callback|
        if callback.is_a?(Proc)
          instance_exec(*args, &callback)
        else
          send(callback, *args)
        end
      end
    end

    module ClassMethods
      def define_callback(callback_name)
        attribute_name = "_#{callback_name}_callbacks"
        class_attribute(attribute_name)
        self.send("#{attribute_name}=", [])
        define_singleton_method(callback_name) do |*args, &block|
          callbacks = self.send(attribute_name)
          callbacks.concat(args)
          callbacks.push(block) if block_given?
          self.send("#{attribute_name}=", callbacks)
        end
      end

      def callbacks_for(callback_name)
        attribute_name = "_#{callback_name}_callbacks"
        if superclass.respond_to? :callbacks_for
          superclass.callbacks_for(callback_name)
        else
          []
        end + self.send(attribute_name)
      end
    end
  end
end
