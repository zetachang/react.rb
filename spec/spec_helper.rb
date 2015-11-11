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

  require 'reactive-ruby'

  # allows you to say

  # rendering "test title" do
  #   div { "foo" }
  # end.will_immediately_generate do
  #   html == "<div><span>foo</span></div>"
  # end

  # will_immediately_generate can be replaced with will_generate which will keep retrying until it gets it right

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

  module ReactTestHelpers
    `var ReactTestUtils = React.addons.TestUtils`

    def renderToDocument(type, options = {})
      element = React.create_element(type, options)
      return renderElementToDocument(element)
    end

    def renderElementToDocument(element)
      instance = Native(`ReactTestUtils.renderIntoDocument(#{element.to_n})`)
      instance.class.include(React::Component::API)
      return instance
    end

    def simulateEvent(event, element, params = {})
      simulator = Native(`ReactTestUtils.Simulate`)
      simulator[event.to_s].call(`#{element.to_n}.getDOMNode()`, params)
    end

    def isElementOfType(element, type)
      `React.addons.TestUtils.isElementOfType(#{element.to_n}, #{type.cached_component_class})`
    end

    def build_element(type, options)
      component = React.create_element(type, options)
      element = `ReactTestUtils.renderIntoDocument(#{component.to_n})`
      if `typeof React.findDOMNode === 'undefined'`
        `$(element.getDOMNode())`          # v0.12
      else
        `$(React.findDOMNode(element))`    # v0.13
      end
    end

    def expect_component_to_eventually(component_class, opts = {}, &block)
      # Calls block after each update of a component until it returns true.  When it does set the expectation to true.
      # Uses the after_update callback of the component_class, then instantiates an element of that class
      # The call back is only called on updates, so the call back is manually called right after the
      # element is created.
      # Because React.rb runs the callback inside the components context, we have to
      # setup a lambda to get back to correct context before executing run_async.
      # Because run_async can only be run once it is protected by clearing element once the test passes.
      element = nil
      check_block = lambda do
        context = block.arity > 0 ? self : element
        run_async do
           element = nil; expect(true).to be(true)
        end if element and context.instance_exec(element, &block)
      end
      component_class.after_update { check_block.call  }
      element = build_element component_class, opts
      check_block.call
    end
  end

  RSpec.configure do |config|
    config.include ReactTestHelpers
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
