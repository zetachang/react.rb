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

get '/comments.json' do
  comments = JSON.parse(open("./_comments.json").read)
  JSON.generate(comments)
end

get '/comments.js' do
  content_type "application/javascript"
  comments = JSON.parse(open("./_comments.json").read)
  "window.initial_comments = #{JSON.generate(comments)}"
end

post "/comments.json" do
  comments = JSON.parse(open("./_comments.json").read)
  comments << JSON.parse(request.body.read)
  File.write('./_comments.json', JSON.pretty_generate(comments, :indent => '    '))
  JSON.generate(comments)
end

get '/' do
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Hello React</title>
        <link rel="stylesheet" href="base.css" />
        <script src="http://cdnjs.cloudflare.com/ajax/libs/showdown/0.3.1/showdown.min.js"></script>
        <script src="/assets/example.js"></script>
        <script src="/comments.js"></script>
        <script>#{Opal::Processor.load_asset_code(opal.sprockets, "example.js")}</script>
      </head>
      <body>
        <div id="content"></div>
      </body>
    </html>
  HTML
end

run Sinatra::Application
