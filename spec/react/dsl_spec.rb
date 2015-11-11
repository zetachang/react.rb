require 'spec_helper'

if opal?
describe 'the React DSL' do
  it "will treat the component class name as a first class component name"  # Foo()
  it "can add class names by the haml .class notation"                      # Foo.my_class
  it "can use the 'class' keyword for classes"                              # Foo(class: "my-class")
  it "will turn the last string in a block into a span"                     # Foo { "hello there" }
  it "has a .span short hand String method"                                 # "hello there".span
  it "has a .br short hand String method"
  it "has a .td short hand String method"
  it "has a .para short hand String method"
  it "can generate a unrendered node using the .as_node method"             # div { "hello" }.as_node
  it "can use the dangerously_set_inner_HTML param"                         # div { dangerously_set_inner_HTML: "<div>danger</div>" }
end
end
