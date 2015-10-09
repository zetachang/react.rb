module ReactiveRuby
  module Rails
    class ComponentMount < React::Rails::ComponentMount
      attr_accessor :controller

      def setup(env)
        self.controller = env.request['controller']
      end

      def react_component(name, props = {}, options = {}, &block)
        props = {render_params: props, component_name: name, controller: self.controller.class.name}
        name = 'React.TopLevelRailsComponent'
        if options[:prerender]
          options[:prerender] = {options[:prerender] => true} unless options[:prerender].is_a? Hash
          existing_context_initializer = options[:prerender][:context_initializer]
          options[:prerender][:context_initializer] = lambda do |ctx|
            React::IsomorphicHelpers.load_context(ctx, self.controller, props[:component_name])
            existing_context_initializer.call ctx if existing_context_initializer
          end

        end
        component_rendering = (super(name, props.react_serializer, options, &block))
        footers = React::IsomorphicHelpers.prerender_footers #if options[:prerender]
        component_rendering+footers
      end
    end
  end
end
