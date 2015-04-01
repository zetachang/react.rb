require "spec_helper"

describe React::Element do
  it "should be toll-free bridged to React.Element" do
    element = React.create_element('div')
    expect(`React.isValidElement(#{element})`).to eq(true)
  end
  
  describe "#new" do
    it "should raise error if invokded" do
      expect { React::Element.new }.to raise_error
    end
  end
  
  describe "#element_type" do
    it "should bridge to `type` of native" do
      element = React.create_element('div')
      expect(element.element_type).to eq("div")
      %x{
        var m = React.createClass({
          render:function(){ return React.createElement('div'); }
        });
        var ele = React.createElement(m);
      }
      expect(`ele`.element_type).to eq(`ele.type`)
    end
  end
  
  describe "#key" do
    it "should bridge to `key` of native" do
      element = React.create_element('div', key: "1")
      expect(element.key).to eq(`#{element}.key`)
    end
    
    it "should return nil if key is null" do
      element = React.create_element('div')
      expect(element.key).to be_nil
    end
  end
  
  describe "#ref" do
    it "should bridge to `ref` of native" do
      element = React.create_element('div', ref: "foo")
      expect(element.ref).to eq(`#{element}.ref`)
    end
    
    it "should return nil if ref is null" do
      element = React.create_element('div')
      expect(element.ref).to be_nil
    end
  end

  describe "Event subscription" do
    it "should be subscribable through `on(:event_name)` method" do
      expect { |b|
        element = React.create_element("div").on(:click, &b)
        instance = renderElementToDocument(element)
        simulateEvent(:click, instance)
      }.to yield_with_args(React::Event)

      expect { |b|
        element = React.create_element("div").on(:key_down, &b)
        instance = renderElementToDocument(element)
        simulateEvent(:keyDown, instance, {key: "Enter"})
      }.to yield_control

      expect { |b|
        element = React.create_element("form").on(:submit, &b)
        instance = renderElementToDocument(element)
        simulateEvent(:submit, instance, {})
      }.to yield_control
    end

    it "should return self for `on` method" do
      element = React.create_element("div")
      expect(element.on(:click){}).to eq(element)
    end
  end

  describe "Children" do
    it "should return a Enumerable" do
      ele = React.create_element('div') { [React.create_element('a'), React.create_element('li')] }
      nodes = ele.children.map {|ele| ele.element_type }
      expect(nodes).to eq(["a", "li"])
    end

    it "should return a Enumerator when not providing a block" do
      ele = React.create_element('div') { [React.create_element('a'), React.create_element('li')] }
      nodes = ele.children.each
      expect(nodes).to be_a(Enumerator)
      expect(nodes.size).to eq(2)
    end
  end
end
