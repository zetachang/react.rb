# config.ru
require 'bundler'
Bundler.require

Opal::Processor.source_map_enabled = true

opal = Opal::Server.new {|s|
  s.append_path './app'
  s.main = 'example'
  s.debug = true
}

map opal.source_maps.prefix do
  run opal.source_maps
end rescue nil

map '/assets' do
  run opal.sprockets
end

get '/*' do
  example = "show"
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Example: #{example}.rb</title>
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
