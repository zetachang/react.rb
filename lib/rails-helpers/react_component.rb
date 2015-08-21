begin
  
  require 'react-rails'
  require 'reactive-ruby' #'/prerender_data_interface'
  
  module React
    module Rails
      module ViewHelper

        alias_method :pre_opal_react_component, :react_component

        def react_component(module_style_name, props = {}, render_options={}, &block)
          js_name = module_style_name.gsub("::", ".")
          if render_options[:prerender]
            render_options[:prerender] = {render_options[:prerender] => true} unless render_options[:prerender].is_a? Hash
            existing_context_initializer = render_options[:prerender][:context_initializer]
            render_options[:prerender][:context_initializer] = lambda do |ctx| 
              React::IsomorphicHelpers.load_context(ctx, self)
              existing_context_initializer.call ctx if existing_context_initializer
            end
            
          end
          component_rendering = raw(pre_opal_react_component(js_name, props.react_serializer, render_options, &block))
          footers = React::IsomorphicHelpers.prerender_footers #if render_options[:prerender]
          component_rendering+footers
        end
      end
    end
  end
  
rescue LoadError
end
