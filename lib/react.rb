if RUBY_ENGINE == 'opal'
  require "react/top_level"
  require "react/component"  
  require "react/top_level_component"
  require "react/element"
  require "react/event"
  require "react/version"
  require "react/api"
  require "react/validator"
  require "react/observable"
  require "react/rendering_context"
else
  require "opal"
  require "react/version"
  require "opal-activesupport"

  Opal.append_path File.expand_path('../', __FILE__).untaint
  Opal.append_path File.expand_path('../../vendor', __FILE__).untaint
end
