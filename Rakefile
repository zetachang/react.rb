require 'bundler'
Bundler.require
Bundler::GemHelper.install_tasks

require 'generators/reactive_ruby/test_app/test_app_generator'

desc "Generates a dummy app for testing"
task :test_app do
  ReactiveRuby::TestAppGenerator.start
  puts "Setting up test app database..."
  system("bundle exec rake db:drop db:create db:migrate > #{File::NULL}")
end
