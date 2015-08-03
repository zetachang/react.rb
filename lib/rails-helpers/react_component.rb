begin
  
  require 'react-rails'
  require 'opal-react' #'/prerender_data_interface'
  
  module React
    module Rails
      module ViewHelper

        alias_method :pre_opal_react_component, :react_component

        def react_component(module_style_name, props = {}, render_options={}, &block)
          js_name = module_style_name.gsub("::", ".")
          @prerender_data_interface ||= React::PrerenderDataInterface.new(self)
          @prerender_data_interface.initial_while_loading_counter = @prerender_data_interface.while_loading_counter
          if render_options[:prerender]
            if render_options[:prerender].is_a? Hash 
              render_options[:prerender][:context] ||= {}
            elsif render_options[:prerender]
              render_options[:prerender] = {render_options[:prerender] => true, context: {}} 
            else
              render_options[:prerender] = {context: {}}
            end
            
            render_options[:prerender][:context].merge!({"ServerSidePrerenderDataInterface" => @prerender_data_interface})
            
          end
          
          component_rendering = raw(pre_opal_react_component(js_name, props.react_serializer, render_options, &block))
          initial_data_string = raw(@prerender_data_interface.generate_next_footer) #render_options[:prerender] ? @prerender_data_interface.generate_next_footer : "")
          
          component_rendering+initial_data_string
        end
      end
    end
  end
  
rescue LoadError
end
