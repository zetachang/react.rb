require 'react'

module ReactTestHelpers
  `var ReactTestUtils = React.addons.TestUtils`
  
  def renderToDocument(type, options = {})
    element = React.create_element(type, options)
    return renderElementToDocument(element)
  end
  
  def renderElementToDocument(element)
    instance = `ReactTestUtils.renderIntoDocument(#{element.to_n})`
    return Native(instance)
  end
  
  def simulateEvent(event, element)
    simulator = Native(`ReactTestUtils.Simulate`)
    simulator[event.to_s].call(element.to_n)
  end
end

RSpec.configure do |config|
  config.include ReactTestHelpers
end