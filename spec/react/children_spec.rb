require 'spec_helper'

if opal?
describe React::Children do
  let(:component) {
    Class.new do
      include React::Component
      def render
        div { 'lorem' }
      end
    end
  }
  let(:childs) { [React.create_element('a'), React.create_element('li')] }
  let(:element) { React.create_element(component) { childs } }
  let(:children) { described_class.new(`#{element.to_n}.props.children`) }

  before(:each) do
    renderElementToDocument(element)
  end

  it 'is enumerable' do
    nodes = children.map { |elem| elem.element_type }
    expect(nodes).to eq(['a', 'li'])
  end

  it 'returns an Enumerator when not providing a block' do
    nodes = children.each
    expect(nodes).to be_a(Enumerator)
    expect(nodes.size).to eq(2)
  end

  describe '#each' do
    it 'returns an array of elements' do
      nodes = children.each { |elem| elem.element_type }
      expect(nodes).to be_a(Array)
      expect(nodes.map(&:class)).to eq(childs.map(&:class))
    end
  end

  describe '#length' do
    it 'returns the number of child elements' do
      expect(children.length).to eq(2)
    end
  end

  describe 'with single child element' do
    let(:childs) { [React.create_element('a')] }

    it 'is enumerable containing single element' do
      nodes = children.map { |elem| elem.element_type }
      expect(nodes).to eq(['a'])
    end

    describe '#length' do
      it 'returns the number of child elements' do
        expect(children.length).to eq(1)
      end
    end
  end

  describe 'with no child element' do
    let(:element) { React.create_element(component) }

    it 'is enumerable containing no elements' do
      nodes = children.map { |elem| elem.element_type }
      expect(nodes).to eq([])
    end

    describe '#length' do
      it 'returns the number of child elements' do
        expect(children.length).to eq(0)
      end
    end
  end
end
end
