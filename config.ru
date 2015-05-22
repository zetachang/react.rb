require 'bundler'
Bundler.require

require "opal-rspec"
require 'opal-jquery'

Opal.append_path File.expand_path('../spec', __FILE__)

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.append_path 'spec/vendor'
  s.append_path Opal::React.bundled_path
  s.debug = true
  s.index_path = 'spec/reactjs/index.html.erb'
}
