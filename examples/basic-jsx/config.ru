require 'bundler'
Bundler.require

run Opal::Server.new {|s|
  s.append_path './'
  s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
  s.main = 'example'
  s.index_path = 'index.html.erb'
  s.debug = true
}
