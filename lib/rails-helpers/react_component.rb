begin
  
  require 'react-rails'
  
  module React
    module Rails
      module ViewHelper

        alias_method :js_react_component, :react_component

        def react_component(module_style_name, props, render_options={})
          js_name = module_style_name.gsub("::", ".") 
          js_react_component(js_name, props, render_options)
        end

      end
    end
  end
  
rescue LoadError 
end


