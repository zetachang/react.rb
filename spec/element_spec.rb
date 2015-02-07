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
  
  describe "Event subscription" do
    it "should be subscribable through `on(:event_name)` method" do
      expect { |b|
        element = React.create_element("div").on(:click, &b)
        instance = renderElementToDocument(element)
        simulateEvent(:click, instance)
      }.to yield_control
    end
    
    it "should return self for `on` method" do
      element = React.create_element("div")
      expect(element.on(:click){}).to eq(element)
    end
  end
end