module ReactiveRuby
  module ServerRendering
    def self.context_instance_var_name
      if RUBY_PLATFORM == 'java'
        '@rhino_context'
      else
        '@v8_context'
      end
    end

    class ContextualRenderer < React::ServerRendering::SprocketsRenderer
      def initialize(options = {})
        super(options)
        ComponentLoader.new(v8_context).load
      end

      def render(component_name, props, prerender_options)
        if prerender_options.is_a? Hash
          if v8_runtime? && prerender_options[:context_initializer]
            raise React::ServerRendering::PrerenderError.new(component_name, props, "you must use 'therubyracer' with the prerender[:context] option") unless v8_runtime?
          else
            prerender_options[:context_initializer].call v8_context
            prerender_options = prerender_options[:static] ? :static : true
          end
        end

        super(component_name, props, prerender_options)
      end

      private

      def v8_runtime?
        ExecJS.runtime.name == "(V8)" || ExecJS.runtime.name == "therubyrhino (Rhino)"
      end
      def v8_context
        @v8_context ||= @context.instance_variable_get(ReactiveRuby::ServerRendering.context_instance_var_name)
      end
    end
  end
end
