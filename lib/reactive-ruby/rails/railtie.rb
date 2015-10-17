module ReactiveRuby
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_configuration do |app|
        app.config.assets.enabled = true
        app.config.assets.paths << ::Rails.root.join('app', 'views').to_s
        app.config.react.server_renderer =
          ReactiveRuby::ServerRendering::ContextualRenderer
        app.config.react.view_helper_implementation =
          ReactiveRuby::Rails::ComponentMount
      end
    end
  end
end
