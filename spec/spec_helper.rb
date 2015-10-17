ENV["RAILS_ENV"] ||= 'test'

require 'opal'
require 'opal-rspec'

def opal?
  RUBY_ENGINE == 'opal'
end

def ruby?
  !opal?
end

if RUBY_ENGINE == 'opal'
  RSpec.configure do |config|
    config.filter_run_excluding :ruby
  end
end

if RUBY_ENGINE != 'opal'
  begin
    require File.expand_path('../test_app/config/environment', __FILE__)
  rescue LoadError
    puts 'Could not load test application. Please ensure you have run `bundle exec rake test_app`'
  end
  require 'rspec/rails'
  require 'timecop'

  Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

  RSpec.configure do |config|
    config.color = true
    config.fail_fast = ENV['FAIL_FAST'] || false
    config.fixture_path = File.join(File.expand_path(File.dirname(__FILE__)), "fixtures")
    config.infer_spec_type_from_file_location!
    config.mock_with :rspec
    config.raise_errors_for_deprecations!

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, comment the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    config.before :each do
      Rails.cache.clear
    end

    config.filter_run_including focus: true
    config.filter_run_excluding opal: true
    config.run_all_when_everything_filtered = true
  end
end
