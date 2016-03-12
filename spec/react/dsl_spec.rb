require 'spec_helper'

if opal?
RSpec.describe 'the React DSL', type: :component do
  it "will turn the last string in a block into a element" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        div { "hello" }
      end
    end

    expect(Foo).to render('<div>hello</div>')
  end

  it "has a .span short hand String method" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        div { "hello".span; "goodby".span }
      end
    end

    expect(Foo).to render('<div><span>hello</span><span>goodby</span></div>')
  end

  it "has a .br short hand String method" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        div { "hello".br }
      end
    end

    expect(Foo).to render('<div><span>hello<br></span></div>')
  end

  it "has a .td short hand String method" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        table { tr { "hello".td } }
      end
    end

    expect(Foo).to render('<table><tr><td>hello</td></tr></table>')
  end

  it "has a .para short hand String method" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        div { "hello".para }
      end
    end

    expect(Foo).to render('<div><p>hello</p></div>')
  end

  it "will treat the component class name as a first class component name" do
    stub_const 'Biz::Mod::Bar', Class.new
    Biz::Mod::Bar.class_eval do
      include React::Component
      def render
        "a man walks into a bar"
      end
    end
    stub_const 'Foo', Class.new(React::Component::Base)
    Foo.class_eval do
      def render
        Biz::Mod::Bar()
      end
    end

    expect(Foo).to render('<span>a man walks into a bar</span>')
  end

  it "will treat the component class name as a first class component name" do
    stub_const 'Mod::Bar', Class.new
    Mod::Bar.class_eval do
      include React::Component
      def render
        "a man walks into a bar"
      end
    end
    stub_const 'Foo', Class.new(React::Component::Base)
    Foo.class_eval do
      def render
        Mod::Bar()
      end
    end

    expect(Foo).to render('<span>a man walks into a bar</span>')
  end

  it "can add class names by the haml .class notation" do
    stub_const 'Mod::Bar', Class.new(React::Component::Base)
    Mod::Bar.class_eval do
      collect_other_params_as :attributes
      def render
        "a man walks into a bar".span(params.attributes)
      end
    end
    stub_const 'Foo', Class.new(React::Component::Base)
    Foo.class_eval do
      def render
        Mod::Bar().the_class
      end
    end

    expect(Foo).to render('<span class="the-class">a man walks into a bar</span>')
  end

  it "can use the 'class' keyword for classes" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        span(class: "the-class") { "hello" }
      end
    end

    expect(Foo).to render('<span class="the-class">hello</span>')
  end

  it "can generate a unrendered node using the .as_node method" do          # div { "hello" }.as_node
    stub_const 'Foo', Class.new #(React::Component::Base)
    Foo.class_eval do
      include React::Component
      def render
        span { "hello".span.as_node.class.name }.as_node.render
      end
    end

    expect(Foo).to render('<span>React::Element</span>')
  end

  it "can use the dangerously_set_inner_HTML param" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        div(dangerously_set_inner_HTML:  { __html: "Hello&nbsp;&nbsp;Goodby" })
      end
    end

    expect(Foo).to render('<div>Hello&nbsp;&nbsp;Goodby</div>')
  end

  it "will remove all elements passed as params from the rendering buffer" do
    stub_const 'X2', Class.new
    X2.class_eval do
      include React::Component
      param :ele
      def render
        div do
          ele.render
          ele.render
        end
      end
    end
    stub_const 'Test', Class.new
    Test.class_eval do
      include React::Component
      def render
        X2(ele: b { "hello" })
      end
    end

    expect(Test).to render('<div><b>hello</b><b>hello</b></div>')
  end
end
end
