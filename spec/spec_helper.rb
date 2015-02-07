require 'react'

module ReactTestHelpers
  def renderToDocument(type, options = {})
    `var ReactTestUtils = React.addons.TestUtils`
    element = React.create_element(type, options)
    instance = `ReactTestUtils.renderIntoDocument(#{element.to_n})`
    return Native(instance)
  end
end

RSpec.configure do |config|
  config.include ReactTestHelpers
end