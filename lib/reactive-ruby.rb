if RUBY_ENGINE == 'opal'
  require "sources/react.js"
  require "reactive-ruby/top_level"
  require "reactive-ruby/component"  
  require "reactive-ruby/element"
  require "reactive-ruby/event"
  require "reactive-ruby/version"
  require "reactive-ruby/api"
  require "reactive-ruby/validator"
  require "reactive-ruby/observable"
  require "reactive-ruby/rendering_context"
  require "reactive-ruby/state"
  require "reactive-ruby/isomorphic_helpers"
  require "rails-helpers/top_level_rails_component"
  
else
  require "opal"
  require "opal-rails"
  require "opal-browser"
  require "reactive-ruby/version"
  require "opal-activesupport"
  require "reactive-ruby/rails" if defined?(Rails)
  require "reactive-ruby/isomorphic_helpers"
  require "reactive-ruby/serializers"

  Opal.append_path File.expand_path('../', __FILE__).untaint
end
