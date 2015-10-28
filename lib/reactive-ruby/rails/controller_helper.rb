require 'action_controller'

module ReactiveRuby
  module Rails
    class ActionController::Base
      def render_component(*args)
        @component_name = ((args[0].is_a? Hash) || args.empty?) ? params[:action].camelize : args.shift
        @render_params = (args[0].is_a? Hash) ? args[0] : {}
        render inline: "<%= react_component @component_name, @render_params, { prerender: !params[:no_prerender] } %>", layout: 'application'
      end
    end
  end
end
