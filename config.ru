require 'bundler'
Bundler.require

require "opal/rspec"
require "opal-jquery"

Opal.append_path File.expand_path('../spec', __FILE__)

sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.add_spec_paths_to_sprockets
  s.debug = false
  s.index_path = 'spec/index.html.erb'
}

# run Opal::Server.new { |s|
#   s.main = 'opal/rspec/sprockets_runner'
#   s.append_path 'spec'
#   #s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
#   s.debug = true
#   s.index_path = 'spec/index.html.erb'
# }
