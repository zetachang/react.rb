if RUBY_ENGINE == 'opal'
  require 'sources/react.js'
  require 'react/top_level'
  require 'react/component'
  require 'react/element'
  require 'react/event'
  require 'react/api'
  require 'react/validator'
  require 'react/observable'
  require 'react/rendering_context'
  require 'react/state'
  require 'reactive-ruby/isomorphic_helpers'
  require 'rails-helpers/top_level_rails_component'
  require 'reactive-ruby/version'
else
  require 'opal'
  require 'opal-browser'
  require 'opal-activesupport'
  require 'reactive-ruby/version'
  require 'reactive-ruby/rails' if defined?(Rails)
  require 'reactive-ruby/isomorphic_helpers'
  require 'reactive-ruby/serializers'

  Opal.append_path File.expand_path('../', __FILE__).untaint
end
