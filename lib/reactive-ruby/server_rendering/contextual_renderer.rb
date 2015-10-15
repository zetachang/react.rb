module ReactiveRuby
  module ServerRendering
    class ContextualRenderer < React::ServerRendering::SprocketsRenderer
      def initialize(options = {})
        super(options)
        load_components
      end

      def render(component_name, props, prerender_options)
        if prerender_options.is_a? Hash
          if v8_runtime? and prerender_options[:context_initializer]
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
        ExecJS.runtime.name == "(V8)"
      end

      def v8_context
        @v8_context ||= @context.instance_variable_get("@v8_context")
      end

      def load_components
        v8_context.eval(processed_opal_asset)
      end

      def processed_opal_asset
        Opal::Processor.load_asset_code(::Rails.application.assets,'components')
      end
    end
  end
end
