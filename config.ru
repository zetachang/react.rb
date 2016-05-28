require 'bundler'
Bundler.require

require "opal-rspec"
require "opal-jquery"
#require "react/source"

Opal.append_path File.expand_path('../spec', __FILE__)

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  #s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
  s.debug = true
  s.index_path = 'spec/index.html.erb'
}
