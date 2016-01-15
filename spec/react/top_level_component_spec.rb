require 'spec_helper'

if opal?
module Components
  module Controller
    class Component1
      include React::Component
      def render
        self.class.name.to_s
      end
    end
  end

  class Component1
    include React::Component
    def render
      self.class.name.to_s
    end
  end

  class Component2
    include React::Component
    def render
      self.class.name.to_s
    end
  end
end

module Controller
  class SomeOtherClass  # see issue #80
  end
end

class Component1
  include React::Component
  def render
    self.class.name.to_s
  end
end

def render_top_level(controller, component_name)
  render_to_html(React::TopLevelRailsComponent, controller: controller,
                 component_name: component_name, render_params: {})
end

describe React::TopLevelRailsComponent do

  it 'uses the controller name to lookup a component' do
    expect(render_top_level("Controller", "Component1")).to eq('<span>Components::Controller::Component1</span>')
  end

  it 'can find the name without matching the controller' do
    expect(render_top_level("Controller", "Component2")).to eq('<span>Components::Component2</span>')
  end

  it 'will find the outer most matching component' do
    expect(render_top_level("OtherController", "Component1")).to eq('<span>Component1</span>')
  end

  it 'can find the correct component when the name is fully qualified' do
    expect(render_top_level("Controller", "::Components::Component1")).to eq('<span>Components::Component1</span>')
  end

  describe '.html_tag?' do
    it 'is truthy for valid html tags' do
      expect(React.html_tag?('a')).to be_truthy
      expect(React.html_tag?('div')).to be_truthy
    end

    it 'is truthy for valid svg tags' do
      expect(React.html_tag?('svg')).to be_truthy
      expect(React.html_tag?('circle')).to be_truthy
    end

    it 'is falsey for invalid tags' do
      expect(React.html_tag?('tagizzle')).to be_falsey
    end
  end

  describe '.html_attr?' do
    it 'is truthy for valid html attributes' do
      expect(React.html_attr?('id')).to be_truthy
      expect(React.html_attr?('data')).to be_truthy
    end

    it 'is truthy for valid svg attributes' do
      expect(React.html_attr?('cx')).to be_truthy
      expect(React.html_attr?('strokeWidth')).to be_truthy
    end

    it 'is falsey for invalid attributes' do
      expect(React.html_tag?('attrizzle')).to be_falsey
    end
  end
end
end
