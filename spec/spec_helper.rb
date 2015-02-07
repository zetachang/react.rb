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
end

RSpec.configure do |config|
  config.include ReactTestHelpers
end