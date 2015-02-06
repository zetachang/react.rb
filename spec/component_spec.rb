require "spec_helper"

describe React::Component do
  describe "Life Cycle" do
    before do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component
        def render
          React.create_element("div") { "lorem" }
        end
      end
    end
    
    it "should invoke `before_mount` registered methods when `componentWillMount()`" do        
      Foo.class_eval do
        before_mount :bar, :bar2
        def bar; end
        def bar2; end
      end
      
      expect_any_instance_of(Foo).to receive(:bar)
      expect_any_instance_of(Foo).to receive(:bar2)
      
      renderToDocument(Foo)
    end
    
    it "should invoke `after_mount` registered methods when `componentDidMount()`" do
      Foo.class_eval do
        after_mount :bar3, :bar4
        def bar3; end
        def bar4; end
      end

      expect_any_instance_of(Foo).to receive(:bar3)
      expect_any_instance_of(Foo).to receive(:bar4)

      renderToDocument(Foo)
    end
  end
  
  describe "State setter & getter" do
    before do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component
        def render
          React.create_element("div") { "lorem" }
        end
      end
    end
    
    it "should define setter & getter by using `define_state`" do
      Foo.class_eval do
        define_state :s1
      end
      
      element = renderToDocument(Foo)
      expect(element.state.foo).to be("bar")
    end
  end
  
  pending "props (a.k.a params)"
end