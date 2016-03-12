require 'spec_helper'

if opal?
class HelloMessage
  include React::Component
  def render
    div { "Hello World!" }
  end
end

describe 'An Example from the react.rb doc', type: :component do
  it 'produces the correct result' do
    expect(HelloMessage).to render('<div>Hello World!</div>')
  end
end

class HelloMessage2
  include React::Component
  define_state(:user_name) { '@catmando' }
  def render
    div { "Hello #{state.user_name}" }
  end
end

describe 'Adding state to a component (second tutorial example)', type: :component do
  it "produces the correct result" do
    expect(HelloMessage2).to render('<div>Hello @catmando</div>')
  end

  it 'renders to the document' do
    React.render(React.create_element(HelloMessage2), `document.getElementById('render_here')`)
    expect(`document.getElementById('render_here').innerHTML`) =~ 'Hello @catmando'
  end
end
end
