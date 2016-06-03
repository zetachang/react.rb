ENV["RAILS_ENV"] ||= 'test'

require 'opal'
require 'opal-rspec'
require 'opal-jquery'

def opal?
  RUBY_ENGINE == 'opal'
end

def ruby?
  !opal?
end


if RUBY_ENGINE == 'opal'
  require File.expand_path('../vendor/jquery-2.2.4.min', __FILE__)
  require 'react-latest'
  require 'reactrb'
  require File.expand_path('../support/react/spec_helpers', __FILE__)

  module Opal
    module RSpec
      module AsyncHelpers
        module ClassMethods
          def rendering(title, &block)
            klass = Class.new do
              include React::Component

              def self.block
                @block
              end

              def self.name
                "dummy class"
              end

              def render
                instance_eval &self.class.block
              end

              def self.should_generate(opts={}, &block)
                sself = self
                @self.async(@title, opts) do
                  expect_component_to_eventually(sself, &block)
                end
              end

              def self.should_immediately_generate(opts={}, &block)
                sself = self
                @self.it(@title, opts) do
                  element = build_element sself, {}
                  context = block.arity > 0 ? self : element
                  expect((element and context.instance_exec(element, &block))).to be(true)
                end
              end

            end
            klass.instance_variable_set("@block", block)
            klass.instance_variable_set("@self", self)
            klass.instance_variable_set("@title", "it can render #{title}")
            klass
          end
        end
      end
    end
  end


  RSpec.configure do |config|
    config.include React::SpecHelpers
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
