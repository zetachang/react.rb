require 'react'

module ReactTestHelpers
  `var ReactTestUtils = React.addons.TestUtils`

  def renderToDocument(type, options = {})
    element = React.create_element(type, options)
    return renderElementToDocument(element)
  end

  def renderElementToDocument(element)
    `ReactTestUtils.renderIntoDocument(#{element})`
  end

  def simulateEvent(event, component, params = {})
    simulator = Native(`ReactTestUtils.Simulate`)
    simulator[event.to_s].call(`React.findDOMNode(#{component})`, params)
  end

  def isElementOfType(element, type)
    `React.addons.TestUtils.isElementOfType(#{element}, #{type.cached_component_class})`
  end
end

RSpec.configure do |config|
  config.include ReactTestHelpers
end
