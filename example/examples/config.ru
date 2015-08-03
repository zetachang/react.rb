# config.ru
require 'bundler'
Bundler.require

require "react/source"

Opal::Processor.source_map_enabled = true

opal = Opal::Server.new {|s|
  s.append_path './'
  s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
  s.main = 'example'
  s.debug = true
}

map opal.source_maps.prefix do
  run opal.source_maps
end rescue nil

map '/assets' do
  run opal.sprockets
end

get '/example/:example' do
  example = params[:example]
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Example: #{example}.rb</title>
        <script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
        <script src="http://cdnjs.cloudflare.com/ajax/libs/showdown/0.3.1/showdown.min.js"></script>
        <script src="/assets/react-with-addons.min.js"></script>
        <script src="/assets/#{example}.js"></script>
        <script>#{Opal::Processor.load_asset_code(opal.sprockets, example+".js")}</script>
      </head>
      <body>
        <div id="content"></div>
      </body>
    </html>
  HTML
end

run Sinatra::Application
