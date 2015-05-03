require 'bundler'
Bundler.require

require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default) do |s|
  s.append_path 'app'
  s.append_path 'vendor'
end
