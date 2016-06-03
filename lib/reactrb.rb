

if RUBY_ENGINE == 'opal'
  if `window.React === undefined || window.React.version === undefined`
    raise [
      "No React.js Available",
      "",
      "React.js must be defined before requiring 'reactive-ruby'",
      "'reactive-ruby' has been tested with react v13, v14, and v15.",
      "",
      "IF USING 'react-rails':",
      "   add 'require \"react\"' immediately before the 'require \"reactive-ruby\" directive in 'views/components.rb'.",
      "IF USING WEBPACK:",
      "   add 'react' to your webpack manifest.",
      "OTHERWISE TO GET THE LATEST TESTED VERSION",
      "   add 'require \"react-latest\"' immediately before the require of 'reactive-ruby',",
      "OR TO USE A SPECIFIC VERSION",
      "   add 'require \"react-v1x\"' immediately before the require of 'reactive-ruby'."
    ].join("\n")
  end
  require 'react/hash'
  require 'react/top_level'
  require 'react/observable'
  require 'react/component'
  require 'react/component/base'
  require 'react/element'
  require 'react/event'
  require 'react/api'
  require 'react/validator'
  require 'react/rendering_context'
  require 'react/state'
  require 'reactive-ruby/isomorphic_helpers'
  require 'rails-helpers/top_level_rails_component'
  require 'reactive-ruby/version'

else
  require 'opal'
  require 'opal-browser'
  begin
    require 'opal-jquery'
  rescue LoadError
  end
  require 'opal-activesupport'
  require 'reactive-ruby/version'
  require 'reactive-ruby/rails' if defined?(Rails)
  require 'reactive-ruby/isomorphic_helpers'
  require 'reactive-ruby/serializers'

  Opal.append_path File.expand_path('../', __FILE__).untaint
  Opal.append_path File.expand_path('../sources/', __FILE__).untaint
end
