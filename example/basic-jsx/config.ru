# config.ru
require 'bundler'
Bundler.require

Opal::Processor.source_map_enabled = true

opal = Opal::Server.new {|s|
  s.append_path './'
  s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
  s.main = 'example'
  s.debug = true
}

map opal.source_maps.prefix do
  run opal.source_maps
end

map '/assets' do
  run opal.sprockets
end

get '/' do
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Hello React</title>
        <script src="/assets/react-with-addons.js"></script>
      </head>
      <body>
        <div id="container"></div>
        <script src="/assets/example.js"></script>
      </body>
    </html>
  HTML
end

run Sinatra::Application
