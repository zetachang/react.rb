require 'react'

module ReactTestHelpers
  def renderToDocument(type)
    `var ReactTestUtils = React.addons.TestUtils`
    instance = `ReactTestUtils.renderIntoDocument(#{React.create_element(type).to_n})`
    return Native(instance)
  end
end

RSpec.configure do |config|
  config.include ReactTestHelpers
end