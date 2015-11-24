require 'spec_helper'

if opal?

describe 'React::State' do
  # class Foo; export_state :foo; end # accessible as Foo.foo outside
  it "can created static exported states" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      export_state(:foo) { 'bar' }
    end

    expect(Foo.foo).to eq('bar')
  end

  # these will all require async operations and testing to see if things get re-rendered see spec_helper the "render" test method
  it "sets up observers when exported states are read"                      # if Foo.foo is used during rendering then when Foo.foo changes we will rerender
  it "can be accessed outside of react using get/set_state"                 # React::State.set_state(object, attribute, value) + React::State.get_state(object, attribute)
end

end
