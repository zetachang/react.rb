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
    before(:each) do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component
        def render
          React.create_element("div") { "lorem" }
        end
      end
    end
    
    it "should define setter using `define_state`" do
      Foo.class_eval do
        define_state :foo
        before_mount :set_up
        def set_up
          self.foo = "bar"
        end
      end
      
      element = renderToDocument(Foo)
      expect(element.state.foo).to be("bar")
    end
    
    it "should define init state by passing a block to `define_state`" do
      Foo.class_eval do
        define_state(:foo) { 10 }
      end
      
      element = renderToDocument(Foo)
      expect(element.state.foo).to be(10)
    end
    
    it "should define getter using `define_state`" do
      Foo.class_eval do
        define_state(:foo) { 10 }
        before_mount :bump
        def bump
          self.foo = self.foo + 20
        end
      end
      
      element = renderToDocument(Foo)
      expect(element.state.foo).to be(30)
    end
    
    it "should define multiple state accessor by passing symols array to `define_state`" do
      Foo.class_eval do
        define_state :foo, :foo2
        before_mount :set_up
        def set_up
          self.foo = 10
          self.foo2 = 20
        end
      end
      
      element = renderToDocument(Foo)
      expect(element.state.foo).to be(10)
      expect(element.state.foo2).to be(20)
    end
    
    it "should invoke `define_state` multiple times to define states" do
      Foo.class_eval do
        define_state(:foo) { 30 }
        define_state(:foo2) { 40 }
      end
      
      element = renderToDocument(Foo)
      expect(element.state.foo).to be(30)
      expect(element.state.foo2).to be(40)
    end
    
    it "should raise error if multiple states and block given at the same time" do
      expect  { 
        Foo.class_eval do
          define_state(:foo, :foo2) { 30 }
        end
      }.to raise_error
    end
    
    it "should get state in render method" do
      Foo.class_eval do
        define_state(:foo) { 10 }
        def render
          React.create_element("div") { self.foo }
        end
      end
      
      element = renderToDocument(Foo)
      expect(element.getDOMNode.textContent).to eq("10")
    end
  end
  
  describe "this.props could be accessed through `params` method" do
    before do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component
      end
    end
    
    it "should read from parent passed properties through `params`" do
      Foo.class_eval do
        def render
          React.create_element("div") { params["prop"] }
        end
      end
      
      element = renderToDocument(Foo, prop: "foobar")
      expect(element.getDOMNode.textContent).to eq("foobar")
    end
  end
end