require "spec_helper"

describe React::ElementBuilder do
  it "should build DOM element in builder context" do
    element = React::ElementBuilder.build do
      div do
        span
        span do
          div
        end
      end
    end

    expect(element.element_type).to eq("div")
    expect(element.map {|ele| ele.element_type}).to eq(["span", "span"])
    expect(React.render_to_static_markup(element)).to eq("<div><span></span><span><div></div></span></div>")
  end
  
  it "should build custom React.Component in builder context" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        React.create_element("div")
      end
    end
    
    element = React::ElementBuilder.build do
      render(Foo) do
        div
        div
      end
    end
    
    expect(isElementOfType(element, Foo)).to eq(true)
    expect(element.map {|ele| ele.element_type}).to eq(["div", "div"])
    expect(React.render_to_static_markup(element)).to eq("<div></div>")
  end
end