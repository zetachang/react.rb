module ReactiveRuby
  module Rails
    class ComponentMount < React::Rails::ComponentMount
      attr_accessor :controller

      def setup(env)
        self.controller = env.request['controller']
      end

      def react_component(name, props = {}, options = {}, &block)
        options = context_initializer_options(options, name) if options[:prerender]
        props = serialized_props(props, name, controller)
        super(top_level_name, props, options, &block) + footers
      end

      private

      def context_initializer_options(options, name)
        options[:prerender] = {options[:prerender] => true} unless options[:prerender].is_a? Hash
        existing_context_initializer = options[:prerender][:context_initializer]

        options[:prerender][:context_initializer] = lambda do |ctx|
          React::IsomorphicHelpers.load_context(ctx, controller, name)
          existing_context_initializer.call ctx if existing_context_initializer
        end

        options
      end

      def serialized_props(props, name, controller)
        { render_params: props, component_name: name,
          controller: controller.class.name }.react_serializer
      end

      def top_level_name
        'React.TopLevelRailsComponent'
      end

      def footers
        React::IsomorphicHelpers.prerender_footers #if options[:prerender]
      end
    end
  end
end
