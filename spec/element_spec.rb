require "spec_helper"

describe React::Element do
  it "should bridge `type` of native React.Element attributes" do
    element = React.create_element('div')
    expect(element.element_type).to eq("div")
  end
  
  async "should be renderable" do
    element = React.create_element('span')
    div = `document.createElement("div")`
    React.render(element, div) do
      run_async {
        expect(`div.children[0].tagName`).to eq("SPAN")
      }
    end
  end
  
  it "should be event-subscribable through `on(:event_name)` method" do
    expect { |b|
      element = React.create_element("div").on(:click, &b)
      simulateEvent(:click, element)
      `var ReactTestUtils = React.addons.TestUtils`
      instance = renderElementToDocument(element)
      `React.addons.TestUtils.Simulate.click(#{instance.to_n})`
    }.to yield_control
  end
end