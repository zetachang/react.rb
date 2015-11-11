require 'spec_helper'

if opal?
class HelloMessage
  include React::Component
  def render
    div { "Hello World!" }
  end
end

describe 'An Example from the react.rb doc' do
  it 'produces the correct result' do
    expect(React.render_to_static_markup(React.create_element(HelloMessage))).to eq('<div>Hello World!</div>')
  end
end

class HelloMessage2
  include React::Component
  define_state(:user_name) { '@catmando' }
  def render
    div { "Hello #{user_name}" }
  end
end

describe 'Adding state to a component (second tutorial example)' do
  it "produces the correct result" do
    expect(React.render_to_static_markup(React.create_element(HelloMessage2))).to eq('<div>Hello @catmando</div>')
  end

  it 'renders to the document' do
    React.render(React.create_element(HelloMessage2), `document.getElementById('render_here')`)
    expect(`document.getElementById('render_here').innerHTML`) =~ 'Hello @catmando'
  end
end
end
