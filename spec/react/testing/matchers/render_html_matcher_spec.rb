require 'spec_helper'

if opal?
describe React::Testing::Matchers::RenderHTMLMatcher do
  let(:component) {
    Class.new do
      include React::Component
      params do
        optional :string
      end
      def render
        div do
          span { params.string } if params.string
          'lorem'
        end
      end
    end
  }
  let(:expected) { '<div>lorem</div>' }
  let(:matcher) { described_class.new(expected) }

  describe '#matches?' do
    it 'is truthy when rendered component html equals expected html' do
      expect(matcher.matches?(component)).to be_truthy
    end

    it 'is falsey when rendered component html does not equal expected html' do
      matcher = described_class.new('foo')
      expect(matcher.matches?(component)).to be_falsey
    end
  end

  describe '#with_params' do
    let(:expected) { '<div><span>str</span>lorem</div>' }

    it 'renders the component with the given params' do
      matcher.with_params(string: 'str')
      expect(matcher.matches?(component)).to be_truthy
    end
  end

  describe '#failure_message' do
    let(:expected) { '<div><span>str</span>lorem</div>' }

    it 'includes the name of the component' do
      stub_const 'Foo', component
      matcher.matches?(Foo)
      expect(matcher.failure_message).to match(/expected 'Foo'/)
    end

    it 'includes the params hash' do
      matcher.with_params(string: 'bar')
      matcher.matches?(component)
      expect(matcher.failure_message).to match(/with params '{"string"=>"bar"}'/)
    end

    it 'includes the expected html value' do
      matcher.matches?(component)
      expect(matcher.failure_message).to match(/to render '#{expected}'/)
    end

    it 'includes the actual html value' do
      actual = '<div>lorem<\/div>'
      matcher.matches?(component)
      expect(matcher.failure_message).to match(/, but '#{actual}' was rendered/)
    end

    it 'does not include "to not render"' do
      matcher.matches?(component)
      expect(matcher.failure_message).to_not match(/to not render/)
    end
  end

  describe '#negative_failure_message' do
    let(:expected) { '<div><span>str</span>lorem</div>' }

    it 'includes "to not render"' do
      matcher.matches?(component)
      expect(matcher.negative_failure_message).to match(/to not render/)
    end
  end
end
end
