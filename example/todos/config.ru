require 'bundler'
Bundler.require

require "react/source"

run Opal::Server.new { |s|
  s.append_path 'app'
  s.append_path 'vendor'
  s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))

  s.debug = true
  s.main = 'application'
  s.index_path = 'index.html.haml'
}
