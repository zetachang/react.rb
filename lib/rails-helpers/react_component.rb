begin
  
  require 'react-rails'
  require 'reactive-ruby'
  
  class ActionController::Base

    def render_component(*args)
      component_name = ((args[0].is_a? Hash) || args.empty?) ? params[:action].camelize : args.shift
      controller = params[:controller].camelize
      rails_react_variables = (args[0].is_a? Hash) ? args[0] : {}
      @render_params = {component_name: component_name, controller: controller, render_params: rails_react_variables}
      render inline: "<%= react_component 'React.TopLevelRailsComponent', @render_params, { prerender: !params[:no_prerender] } %>", layout: 'application'
    end

  end
  
  module React
    
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        config.assets.enabled = true
        config.assets.paths << ::Rails.root.join('app', 'views').to_s
      end
    end
    
    module Rails
      module ViewHelper

        alias_method :pre_opal_react_component, :react_component

        def react_component(name, props = {}, render_options={}, &block)
          if render_options[:prerender]
            render_options[:prerender] = {render_options[:prerender] => true} unless render_options[:prerender].is_a? Hash
            existing_context_initializer = render_options[:prerender][:context_initializer]
            render_options[:prerender][:context_initializer] = lambda do |ctx| 
              React::IsomorphicHelpers.load_context(ctx, self)
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
