require 'spec_helper'

RSpec.describe ReactiveRuby::ServerRendering::ContextualRenderer do
  let(:renderer) { described_class.new({}) }
  let(:init) { Proc.new {} }
  let(:options) { { context_initializer: init } }

  describe '#render' do
    it 'pre-renders HTML' do
      result = renderer.render('Components.Todo',
                               { todo: 'finish reactive-ruby' },
                               options)
      expect(result).to match(/<li.*>finish reactive-ruby<\/li>/)
      expect(result).to match(/data-react-checksum/)
    end

    it 'accepts props as a string' do
      result = renderer.render('Components.Todo',
                               { todo: 'finish reactive-ruby' }.to_json,
                               options)
      expect(result).to match(/<li.*>finish reactive-ruby<\/li>/)
      expect(result).to match(/data-react-checksum/)
    end

    it 'pre-renders static content' do
      result = renderer.render('Components.Todo',
                               { todo: 'finish reactive-ruby' },
                               :static)
      expect(result).to match(/<li.*>finish reactive-ruby<\/li>/)
      expect(result).to_not match(/data-react-checksum/)
    end
  end
end
