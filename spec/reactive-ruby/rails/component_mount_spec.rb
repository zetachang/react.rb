require 'spec_helper'

RSpec.describe ReactiveRuby::Rails::ComponentMount do
  let(:helper) { described_class.new }

  before do
    env = double
    allow(env).to receive(:request).and_return(
      { 'controller' => ActionView::TestCase::TestController.new })
    helper.setup(env)
  end

  describe '#react_component' do
    it 'renders a div' do
      html = helper.react_component('Components::HelloWorld')
      expect(html).to match(/<div.*><\/div>/)
    end

    it 'accepts a pre-render option' do
      html = helper.react_component('Components::HelloWorld', {}, prerender: true)
      expect(html).to match(/<div.*><span.*>Hello, World!<\/span><\/div>/)
    end

    it 'sets data-react-class to React.TopLevelRailsComponent' do
      html = helper.react_component('Components::HelloWorld')
      top_level_class = 'React.TopLevelRailsComponent'
      expect(attr_value(html, 'data-react-class')).to eq(top_level_class)
    end

    it 'sets component_name in data-react-props hash' do
      html = helper.react_component('Components::HelloWorld')
      props = react_props_for(html)

      expect(props['component_name']).to eq('Components::HelloWorld')
    end

    it 'sets render_params in data-react-props hash' do
      html = helper.react_component('Components::HelloWorld', {'foo' => 'bar'})
      props = react_props_for(html)

      expect(props['render_params']).to include({ 'foo' => 'bar' })
    end

    it 'sets controller in data-react-props hash' do
      html = helper.react_component('Components::HelloWorld')
      props = react_props_for(html)

      expect(props['controller']).to eq('ActionView::TestCase::TestController')
    end

    it 'passes additional options through as html attributes' do
      html = helper.react_component('Components::HelloWorld', {},
                                    { 'foo-bar' => 'biz-baz' })

      expect(attr_value(html, 'foo-bar')).to eq('biz-baz')
    end
  end

  def attr_value(html, attr)
    matches = html.match(/#{attr}=["']((?:.(?!["']\s+(?:\S+)=|[>"']))+.)["']?/)
    matches.captures.first
  end

  def react_props_for(html)
    JSON.parse(CGI.unescapeHTML("#{attr_value(html, 'data-react-props')}"))
  end
end
