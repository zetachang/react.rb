# config.ru
require 'bundler'
Bundler.require

require "react/source"

opal = Opal::Server.new {|s|
  s.append_path './'
  s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
  s.main = 'example'
  s.debug = true
  s.index_path = "index.html.erb"
}

map opal.source_maps.prefix do
  run opal.source_maps
end

map '/assets' do
  run opal.sprockets
end

get '/comments.json' do
  comments = JSON.parse(open("./_comments.json").read)
  JSON.generate(comments)
end

post "/comments.json" do
  comments = JSON.parse(open("./_comments.json").read)
  comments << JSON.parse(request.body.read)
  File.write('./_comments.json', JSON.pretty_generate(comments, :indent => '    '))
  JSON.generate(comments)
end

map '/' do
  # Sourcemap won't work if only `assets/example.js` is loaded
  use Opal::Server::Index, opal
end

run Sinatra::Application
