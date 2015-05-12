require 'react'
require 'react/testing'
require 'debug_formatter'

RSpec.configure do |config|
  config.include React::Testing
  config.after :each do
    React::ComponentFactory.clear_component_class_cache
  end
  # Want some stack traces
  config.formatter = DebugFormatter
end
