require "spec_helper"

describe React::Element do
  it "should bridge `type` of native React.Element attributes" do
    element = React::Element.new(React.create_element('div'))
    expect(element.element_type).to eq("div")
  end
end