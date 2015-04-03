require 'react'

module ReactTestHelpers
  `var ReactTestUtils = React.addons.TestUtils`

  def renderToDocument(type, options = {})
    element = React.create_element(type, options)
    return renderElementToDocument(element)
  end

  def renderElementToDocument(element)
    instance = Native(`ReactTestUtils.renderIntoDocument(#{element})`)
    instance.class.include(React::Component::API)
    return instance
  end

  def simulateEvent(event, component, params = {})
    simulator = Native(`ReactTestUtils.Simulate`)
    simulator[event.to_s].call(`#{component.to_n}.getDOMNode()`, params)
  end

  def isElementOfType(element, type)
    `React.addons.TestUtils.isElementOfType(#{element}, #{type.cached_component_class})`
  end
end

RSpec.configure do |config|
  config.include ReactTestHelpers
end
