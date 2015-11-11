require "spec_helper"

if opal?
describe React::Element do
  it 'bridges `type` of native React.Element attributes' do
    element = React.create_element('div')
    expect(element.element_type).to eq("div")
  end

  async 'is renderable' do
    element = React.create_element('span')
    div = `document.createElement("div")`
    React.render(element, div) do
      run_async {
        expect(`div.children[0].tagName`).to eq("SPAN")
      }
    end
  end

  describe 'Event subscription' do
    it 'is subscribable through `on(:event_name)` method' do
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

    it 'returns self for `on` method' do
      element = React.create_element("div")
      expect(element.on(:click){}).to eq(element)
    end
  end

  describe '#children' do
    it 'returns an Enumerable' do
      pending 'FIX THIS: broken since reactive-ruby merge'
      ele = React.create_element('div') {
        [React.create_element('a'), React.create_element('li')]
      }
      nodes = ele.children.map { |ele| ele.element_type }
      expect(nodes).to eq(['a', 'li'])
    end

    it 'returns an Enumerator when not providing a block' do
      pending 'FIX THIS: broken since reactive-ruby merge'
      ele = React.create_element('div') {
        [React.create_element('a'), React.create_element('li')]
      }
      nodes = ele.children.each
      expect(nodes).to be_a(Enumerator)
      expect(nodes.size).to eq(2)
    end
  end
end
end
