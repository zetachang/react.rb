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
end