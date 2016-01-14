# -*- encoding: utf-8 -*-
# stub: reactive-ruby 0.8.0 ruby lib

Gem::Specification.new do |s|
  s.name = "reactive-ruby"
  s.version = "0.8.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["David Chang"]
  s.date = "2016-01-11"
  s.description = "Write React UI components in pure Ruby."
  s.email = "zeta11235813@gmail.com"
  s.files = [".codeclimate.yml", ".gitignore", ".travis.yml", "Gemfile", "LICENSE", "README.md", "Rakefile", "config.ru", "example/examples/Gemfile", "example/examples/Gemfile.lock", "example/examples/app/basics.js.rb", "example/examples/app/items.rb", "example/examples/app/jquery.js", "example/examples/app/nodes.rb", "example/examples/app/react-router.js", "example/examples/app/react_api_demo.rb", "example/examples/app/rerendering.rb", "example/examples/app/reuse.rb", "example/examples/app/show.rb", "example/examples/config.ru", "example/rails-tutorial/.gitignore", "example/rails-tutorial/Gemfile", "example/rails-tutorial/Gemfile.lock", "example/rails-tutorial/README.rdoc", "example/rails-tutorial/Rakefile", "example/rails-tutorial/app/assets/images/.keep", "example/rails-tutorial/app/assets/javascripts/application.rb", "example/rails-tutorial/app/assets/stylesheets/application.css", "example/rails-tutorial/app/controllers/application_controller.rb", "example/rails-tutorial/app/controllers/concerns/.keep", "example/rails-tutorial/app/controllers/home_controller.rb", "example/rails-tutorial/app/helpers/application_helper.rb", "example/rails-tutorial/app/mailers/.keep", "example/rails-tutorial/app/models/.keep", "example/rails-tutorial/app/models/concerns/.keep", "example/rails-tutorial/app/views/components.rb", "example/rails-tutorial/app/views/components/home/show.rb", "example/rails-tutorial/app/views/layouts/application.html.erb", "example/rails-tutorial/bin/bundle", "example/rails-tutorial/bin/rails", "example/rails-tutorial/bin/rake", "example/rails-tutorial/bin/setup", "example/rails-tutorial/bin/spring", "example/rails-tutorial/config.ru", "example/rails-tutorial/config/application.rb", "example/rails-tutorial/config/boot.rb", "example/rails-tutorial/config/database.yml", "example/rails-tutorial/config/environment.rb", "example/rails-tutorial/config/environments/development.rb", "example/rails-tutorial/config/environments/production.rb", "example/rails-tutorial/config/environments/test.rb", "example/rails-tutorial/config/initializers/assets.rb", "example/rails-tutorial/config/initializers/backtrace_silencers.rb", "example/rails-tutorial/config/initializers/cookies_serializer.rb", "example/rails-tutorial/config/initializers/filter_parameter_logging.rb", "example/rails-tutorial/config/initializers/inflections.rb", "example/rails-tutorial/config/initializers/mime_types.rb", "example/rails-tutorial/config/initializers/session_store.rb", "example/rails-tutorial/config/initializers/wrap_parameters.rb", "example/rails-tutorial/config/locales/en.yml", "example/rails-tutorial/config/routes.rb", "example/rails-tutorial/config/secrets.yml", "example/rails-tutorial/db/seeds.rb", "example/rails-tutorial/lib/assets/.keep", "example/rails-tutorial/lib/tasks/.keep", "example/rails-tutorial/log/.keep", "example/rails-tutorial/public/404.html", "example/rails-tutorial/public/422.html", "example/rails-tutorial/public/500.html", "example/rails-tutorial/public/favicon.ico", "example/rails-tutorial/public/robots.txt", "example/rails-tutorial/test/controllers/.keep", "example/rails-tutorial/test/fixtures/.keep", "example/rails-tutorial/test/helpers/.keep", "example/rails-tutorial/test/integration/.keep", "example/rails-tutorial/test/mailers/.keep", "example/rails-tutorial/test/models/.keep", "example/rails-tutorial/test/test_helper.rb", "example/rails-tutorial/vendor/assets/javascripts/.keep", "example/rails-tutorial/vendor/assets/stylesheets/.keep", "example/sinatra-tutorial/.DS_Store", "example/sinatra-tutorial/Gemfile", "example/sinatra-tutorial/Gemfile.lock", "example/sinatra-tutorial/README.md", "example/sinatra-tutorial/_comments.json", "example/sinatra-tutorial/app/example.rb", "example/sinatra-tutorial/app/jquery.js", "example/sinatra-tutorial/config.ru", "example/sinatra-tutorial/public/base.css", "lib/generators/reactive_ruby/test_app/templates/application.rb.erb", "lib/generators/reactive_ruby/test_app/templates/assets/javascripts/application.rb", "lib/generators/reactive_ruby/test_app/templates/assets/javascripts/components.rb", "lib/generators/reactive_ruby/test_app/templates/boot.rb.erb", "lib/generators/reactive_ruby/test_app/templates/script/rails", "lib/generators/reactive_ruby/test_app/templates/views/components/hello_world.rb", "lib/generators/reactive_ruby/test_app/templates/views/components/todo.rb", "lib/generators/reactive_ruby/test_app/test_app_generator.rb", "lib/rails-helpers/top_level_rails_component.rb", "lib/react/api.rb", "lib/react/callbacks.rb", "lib/react/children.rb", "lib/react/component.rb", "lib/react/component/api.rb", "lib/react/component/base.rb", "lib/react/component/class_methods.rb", "lib/react/component/props_wrapper.rb", "lib/react/element.rb", "lib/react/event.rb", "lib/react/ext/hash.rb", "lib/react/ext/string.rb", "lib/react/native_library.rb", "lib/react/observable.rb", "lib/react/rendering_context.rb", "lib/react/state.rb", "lib/react/testing/matchers/render_html_matcher.rb", "lib/react/top_level.rb", "lib/react/validator.rb", "lib/reactive-ruby.rb", "lib/reactive-ruby/component_loader.rb", "lib/reactive-ruby/isomorphic_helpers.rb", "lib/reactive-ruby/rails.rb", "lib/reactive-ruby/rails/component_mount.rb", "lib/reactive-ruby/rails/controller_helper.rb", "lib/reactive-ruby/rails/railtie.rb", "lib/reactive-ruby/serializers.rb", "lib/reactive-ruby/server_rendering/contextual_renderer.rb", "lib/reactive-ruby/version.rb", "lib/sources/react.js", "lib/sources/react.js-v12", "logo1.png", "logo2.png", "logo3.png", "path_release_steps.md", "reactive-ruby.gemspec", "spec/controller_helper_spec.rb", "spec/index.html.erb", "spec/react/callbacks_spec.rb", "spec/react/children_spec.rb", "spec/react/component/base_spec.rb", "spec/react/component_spec.rb", "spec/react/dsl_spec.rb", "spec/react/element_spec.rb", "spec/react/event_spec.rb", "spec/react/native_library_spec.rb", "spec/react/observable_spec.rb", "spec/react/param_declaration_spec.rb", "spec/react/react_spec.rb", "spec/react/state_spec.rb", "spec/react/testing/matchers/render_html_matcher_spec.rb", "spec/react/top_level_component_spec.rb", "spec/react/tutorial/tutorial_spec.rb", "spec/react/validator_spec.rb", "spec/reactive-ruby/component_loader_spec.rb", "spec/reactive-ruby/isomorphic_helpers_spec.rb", "spec/reactive-ruby/rails/asset_pipeline_spec.rb", "spec/reactive-ruby/rails/component_mount_spec.rb", "spec/reactive-ruby/server_rendering/contextual_renderer_spec.rb", "spec/spec_helper.rb", "spec/support/react/spec_helpers.rb", "spec/vendor/es5-shim.min.js"]
  s.homepage = "https://reactrb.org"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5"
  s.summary = "Opal Ruby wrapper of React.js library."
  s.test_files = ["spec/controller_helper_spec.rb", "spec/index.html.erb", "spec/react/callbacks_spec.rb", "spec/react/children_spec.rb", "spec/react/component/base_spec.rb", "spec/react/component_spec.rb", "spec/react/dsl_spec.rb", "spec/react/element_spec.rb", "spec/react/event_spec.rb", "spec/react/native_library_spec.rb", "spec/react/observable_spec.rb", "spec/react/param_declaration_spec.rb", "spec/react/react_spec.rb", "spec/react/state_spec.rb", "spec/react/testing/matchers/render_html_matcher_spec.rb", "spec/react/top_level_component_spec.rb", "spec/react/tutorial/tutorial_spec.rb", "spec/react/validator_spec.rb", "spec/reactive-ruby/component_loader_spec.rb", "spec/reactive-ruby/isomorphic_helpers_spec.rb", "spec/reactive-ruby/rails/asset_pipeline_spec.rb", "spec/reactive-ruby/rails/component_mount_spec.rb", "spec/reactive-ruby/server_rendering/contextual_renderer_spec.rb", "spec/spec_helper.rb", "spec/support/react/spec_helpers.rb", "spec/vendor/es5-shim.min.js"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<opal>, ["= 0.8.0"])
      s.add_runtime_dependency(%q<opal-activesupport>, [">= 0.2.0"])
      s.add_runtime_dependency(%q<opal-browser>, ["= 0.2.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec-rails>, ["= 3.3.3"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<opal-rspec>, ["= 0.4.3"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<rails>, ["= 4.2.4"])
      s.add_development_dependency(%q<react-rails>, ["= 1.3.1"])
      s.add_development_dependency(%q<opal-rails>, ["= 0.8.1"])
      s.add_development_dependency(%q<sqlite3>, ["= 1.3.10"])
      s.add_development_dependency(%q<therubyracer>, ["= 0.12.2"])
    else
      s.add_dependency(%q<opal>, ["= 0.8.0"])
      s.add_dependency(%q<opal-activesupport>, [">= 0.2.0"])
      s.add_dependency(%q<opal-browser>, ["= 0.2.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, ["= 3.3.3"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<opal-rspec>, ["= 0.4.3"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<rails>, ["= 4.2.4"])
      s.add_dependency(%q<react-rails>, ["= 1.3.1"])
      s.add_dependency(%q<opal-rails>, ["= 0.8.1"])
      s.add_dependency(%q<sqlite3>, ["= 1.3.10"])
      s.add_dependency(%q<therubyracer>, ["= 0.12.2"])
    end
  else
    s.add_dependency(%q<opal>, ["= 0.8.0"])
    s.add_dependency(%q<opal-activesupport>, [">= 0.2.0"])
    s.add_dependency(%q<opal-browser>, ["= 0.2.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, ["= 3.3.3"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<opal-rspec>, ["= 0.4.3"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<rails>, ["= 4.2.4"])
    s.add_dependency(%q<react-rails>, ["= 1.3.1"])
    s.add_dependency(%q<opal-rails>, ["= 0.8.1"])
    s.add_dependency(%q<sqlite3>, ["= 1.3.10"])
    s.add_dependency(%q<therubyracer>, ["= 0.12.2"])
  end
end
