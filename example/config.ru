# config.ru
require "sinatra"
require "opal"
require "opal-activesupport"
require "react"

Opal::Processor.source_map_enabled = true

#Opal.use_gem "hooks"

opal = Opal::Server.new {|s|
  s.append_path 'app'
  #s.append_path 'vendor_lib'
  #s.use_gem 'uber'
  #s.use_gem 'hooks'
  s.main = 'application'
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
        <script src="/bundle.js"></script>
        <script src="https://code.jquery.com/jquery-2.1.3.min.js"></script>
        <script src="/assets/application.js"></script>
      </head>
    </html>
  HTML
end

run Sinatra::Application