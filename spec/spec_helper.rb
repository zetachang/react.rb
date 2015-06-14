require 'react'
require 'react/testing'

RSpec.configure do |config|
  config.include React::Testing
  config.after :each do
    React::ComponentFactory.clear_component_class_cache
  end
end
