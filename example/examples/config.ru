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

module ShowExample
def self.show_example(example)
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <title>Hello React</title>
        <script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
        <script src="http://cdnjs.cloudflare.com/ajax/libs/showdown/0.3.1/showdown.min.js"></script>
        <script src="/assets/react-with-addons.min.js"></script>
        <script src="/assets/#{example}.js"></script>
      </head>
      <body>
        <div id="content"></div>
      </body>
    </html>
  HTML
end
end



get '/example/:example' do
  puts "hey #{params[:example]}"
  ShowExample.show_example(params[:example])
end

run Sinatra::Application
