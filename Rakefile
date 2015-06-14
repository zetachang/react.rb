require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'

Opal::RSpec::RakeTask.new(:default) do |s|
  s.append_path Opal::React.bundled_path
  s.append_path 'spec/vendor'
  s.index_path = 'spec/reactjs/index.html.erb'
end
