if RUBY_ENGINE == 'opal'
  require "opal-react/top_level"
  require "opal-react/component"  
  require "opal-react/element"
  require "opal-react/event"
  require "opal-react/version"
  require "opal-react/api"
  require "opal-react/validator"
  require "opal-react/observable"
  require "opal-react/rendering_context"
  require "opal-react/state"
  require "opal-react/while_loading"
  require "opal-react/prerender_data_interface"
else
  require "opal"
  require "opal-react/version"
  require "opal-activesupport"
  require "rails-helpers/react_component"

  Opal.append_path File.expand_path('../', __FILE__).untaint
  Opal.append_path File.expand_path('../../vendor', __FILE__).untaint
end
