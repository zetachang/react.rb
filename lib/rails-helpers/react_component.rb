begin
  
  require 'react-rails'
  require 'reactive-ruby'
  
  class ActionController::Base

    def render_component(*args)
      @component_name = ((args[0].is_a? Hash) || args.empty?) ? params[:action].camelize : args.shift
      @render_params = (args[0].is_a? Hash) ? args[0] : {}
      render inline: "<%= react_component @component_name, @render_params, { prerender: !params[:no_prerender] } %>", layout: 'application'
    end

  end
  
  module React
    
    class Railtie < ::Rails::Railtie
      config.before_configuration do |app|
        app.config.assets.enabled = true
        app.config.assets.paths << ::Rails.root.join('app', 'views').to_s
      end
    end
    
    module Rails
      module ViewHelper

        alias_method :pre_opal_react_component, :react_component

        def react_component(name, props = {}, render_options={}, &block)
          props = {render_params: props, component_name: name, controller: self.controller.class.name}
          name = 'React.TopLevelRailsComponent'
          if render_options[:prerender]
            render_options[:prerender] = {render_options[:prerender] => true} unless render_options[:prerender].is_a? Hash
            existing_context_initializer = render_options[:prerender][:context_initializer]
            render_options[:prerender][:context_initializer] = lambda do |ctx| 
              React::IsomorphicHelpers.load_context(ctx, self.controller, props[:component_name])
              existing_context_initializer.call ctx if existing_context_initializer
            end
            
          end
          component_rendering = raw(pre_opal_react_component(name, props.react_serializer, render_options, &block))
          footers = React::IsomorphicHelpers.prerender_footers #if render_options[:prerender]
          component_rendering+footers
        end
      end
    end
  end
  
rescue LoadError
end
