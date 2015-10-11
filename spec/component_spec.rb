require "spec_helper"

describe React::Component do
  it "should define component spec methods" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        React.create_element("div")
      end
    end

    # Class Methods
    expect(Foo).to respond_to("initial_state")
    expect(Foo).to respond_to("default_props")
    expect(Foo).to respond_to("prop_types")

    # Instance method
    expect(Foo.new).to respond_to("component_will_mount")
    expect(Foo.new).to respond_to("component_did_mount")
    expect(Foo.new).to respond_to("component_will_receive_props")
    expect(Foo.new).to respond_to("should_component_update?")
    expect(Foo.new).to respond_to("component_will_update")
    expect(Foo.new).to respond_to("component_did_update")
    expect(Foo.new).to respond_to("component_will_unmount")
  end

  describe "Life Cycle" do
    before(:each) do
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

      render_to_document(React.create_element(Foo))
    end

    it "should invoke `after_mount` registered methods when `componentDidMount()`" do
      Foo.class_eval do
        after_mount :bar3, :bar4
        def bar3; end
        def bar4; end
      end

      expect_any_instance_of(Foo).to receive(:bar3)
      expect_any_instance_of(Foo).to receive(:bar4)

      render_to_document(React.create_element(Foo))
    end

    it "should allow multiple class declared life cycle hooker" do
      stub_const 'FooBar', Class.new
      Foo.class_eval do
        before_mount :bar
        def bar; end
      end

      FooBar.class_eval do
        include React::Component
        after_mount :bar2
        def bar2; end
        def render
          React.create_element("div") { "lorem" }
        end
      end

      expect_any_instance_of(Foo).to receive(:bar)

      render_to_document(React.create_element(Foo))
    end

    it "should allow block for life cycle callback" do
      Foo.class_eval do
        define_state(:foo)

        before_mount do
          self.foo = "bar"
        end
      end

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be("bar")
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

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be("bar")
    end

    it "should define init state by passing a block to `define_state`" do
      Foo.class_eval do
        define_state(:foo) { 10 }
      end

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be(10)
    end

    it "should define getter using `define_state`" do
      Foo.class_eval do
        define_state(:foo) { 10 }
        before_mount :bump
        def bump
          self.foo = self.foo + 20
        end
      end

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be(30)
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

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be(10)
      expect(instance.state[:foo2]).to be(20)
    end

    it "should invoke `define_state` multiple times to define states" do
      Foo.class_eval do
        define_state(:foo) { 30 }
        define_state(:foo2) { 40 }
      end

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be(30)
      expect(instance.state[:foo2]).to be(40)
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

      instance = render_to_document(React.create_element(Foo))
      expect(`#{React.find_dom_node(instance)}.textContent`).to eq("10")
    end

    it "should support original `setState` as `set_state` method" do
      Foo.class_eval do
        before_mount do
          self.set_state(foo: "bar")
        end
      end

      instance = render_to_document(React.create_element(Foo))
      expect(instance.state[:foo]).to be("bar")
    end

    it "should support originl `state` method" do
      Foo.class_eval do
        before_mount do
          self.set_state(foo: "bar")
        end

        def render
          div { self.state[:foo] }
        end
      end

      expect(React.render_to_static_markup(React.create_element(Foo))).to eq("<div>bar</div>")
    end

    it "should transform state getter to Ruby object" do
      Foo.class_eval do
        define_state :foo

        before_mount do
          self.foo = [{a: 10}]
        end

        def render
          div { self.foo[0][:a] }
        end
      end

      expect(React.render_to_static_markup(React.create_element(Foo))).to eq("<div>10</div>")
    end
  end

  describe "Props" do
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
            React.create_element("div") { params[:prop] }
          end
        end

        instance = render_to_document(React.create_element(Foo, prop: "foobar"))
        expect(`#{React.find_dom_node(instance)}.textContent`).to eq("foobar")
      end

      it "should access nested params as orignal Ruby object" do
        Foo.class_eval do
          def render
            React.create_element("div") { params[:prop][0][:foo] }
          end
        end

        instance = render_to_document(React.create_element(Foo, prop: [{foo: 10}]))
        expect(`#{React.find_dom_node(instance)}.textContent`).to eq("10")
      end
    end

    describe "Prop validation" do
      before do
        stub_const 'Foo', Class.new
        Foo.class_eval do
          include React::Component
        end
      end

      it "should specify validation rules using `params` class method" do
        Foo.class_eval do
          params do
            requires :foo, type: String
            optional :bar
          end
        end

        expect(Foo.prop_types).to have_key(:_componentValidator)
      end

      it "should log error in warning if validation failed" do
        stub_const 'Lorem', Class.new
        Foo.class_eval do
          params do
            requires :foo
            requires :lorem, type: Lorem
            optional :bar, type: String
          end

          def render; div; end
        end

        %x{
          var log = [];
          var org_console = window.console;
          window.console = {warn: function(str){log.push(str)}}
        }
        
        begin
          render_to_document(React.create_element(Foo, bar: 10, lorem: Lorem.new))
        
          expect(`log`).to eq(["Warning: Failed propType: In component `Foo`\nRequired prop `foo` was not specified\nProvided prop `bar` was not the specified type `String`"])          
        ensure
          `window.console = org_console;`
        end
      end

      it "should not log anything if validation pass" do
        stub_const 'Lorem', Class.new
        Foo.class_eval do
          params do
            requires :foo
            requires :lorem, type: Lorem
            optional :bar, type: String
          end

          def render; div; end
        end

        %x{
          var log = [];
          var org_console = window.console;
          window.console = {warn: function(str){log.push(str)}}
        }
        begin
          render_to_document(React.create_element(Foo, foo: 10, bar: "10", lorem: Lorem.new))        
          expect(`log`).to eq([])
        ensure
          `window.console = org_console;`
        end        
      end
    end

    describe "Default props" do
      it "should set default props using validation helper" do
        stub_const 'Foo', Class.new
        Foo.class_eval do
          include React::Component
          params do
            optional :foo, default: "foo"
            optional :bar, default: "bar"
          end

          def render
            div { params[:foo] + "-" + params[:bar]}
          end
        end

        expect(React.render_to_static_markup(React.create_element(Foo, foo: "lorem"))).to eq("<div>lorem-bar</div>")
        expect(React.render_to_static_markup(React.create_element(Foo))).to eq("<div>foo-bar</div>")
      end
    end
  end

  describe "Event handling" do
    before do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component
      end
    end

    it "should work in render method" do
      Foo.class_eval do
        define_state(:clicked) { false }

        def render
          React.create_element("div").on(:click) do
            self.clicked = true
          end
        end
      end

      instance = render_to_document(React.create_element(Foo))
      simulate_event(:click, React.find_dom_node(instance))
      expect(instance.state[:clicked]).to eq(true)
    end

    it "should invoke handler on `this.props` using emit" do
      Foo.class_eval do
        after_mount :setup

        def setup
          self.emit(:foo_submit, "bar")
        end

        def render
          React.create_element("div")
        end
      end

      expect { |b|
        element = React.create_element(Foo).on(:foo_submit, &b)
        render_to_document(element)
      }.to yield_with_args("bar")
    end

    it "should invoke handler with multiple params using emit" do
      Foo.class_eval do
        after_mount :setup

        def setup
          self.emit(:foo_invoked, [1,2,3], "bar")
        end

        def render
          React.create_element("div")
        end
      end

      expect { |b|
        element = React.create_element(Foo).on(:foo_invoked, &b)
        render_to_document(element)
      }.to yield_with_args([1,2,3], "bar")
    end
  end

  describe "Refs" do
    before do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component
      end
    end

    it "should correctly assign refs" do
      Foo.class_eval do
        def render
          React.create_element("input", type: :text, ref: :field)
        end
      end

      instance = render_to_document(React.create_element(Foo))
      expect(`#{React.find_dom_node(instance.refs[:field])}.tagName`).to eq('INPUT')
    end

    it "should access refs through `refs` method" do
      Foo.class_eval do
        def render
          React.create_element("input", type: :text, ref: :field).on(:click) do
            input_field = Native(React.find_dom_node(refs[:field]))
            input_field.value = "some_stuff"
          end
        end
      end

      instance = render_to_document(React.create_element(Foo))
      simulate_event(:click, React.find_dom_node(instance))

      expect(`#{React.find_dom_node(instance.refs[:field])}.value`).to eq("some_stuff")
    end
  end

  describe "Render" do
    it "should support element building helpers" do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component

        def render
          div do
            span { params[:foo] }
          end
        end
      end

      stub_const 'Bar', Class.new
      Bar.class_eval do
        include React::Component
        def render
          div do
            present Foo, foo: "astring"
          end
        end
      end

      expect(React.render_to_static_markup(React.create_element(Bar))).to eq("<div><div><span>astring</span></div></div>")
    end

    it "should build single node in top-level render without providing a block" do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component

        def render
          div
        end
      end

      element = React.create_element(Foo)
      expect(React.render_to_static_markup(element)).to eq("<div></div>")
    end

    it "should redefine `p` to make method missing work" do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component

        def render
          p(class_name: "foo") do
            p
            div { "lorem ipsum" }
            p(id: "10")
          end
        end
      end

      element = React.create_element(Foo)
      expect(React.render_to_static_markup(element)).to eq("<p class=\"foo\"><p></p><div>lorem ipsum</div><p id=\"10\"></p></p>")
    end

    it "should only override `p` in render context" do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component

        before_mount do
          p "first"
        end

        after_mount do
          p "second"
        end

        def render
          div
        end
      end

      expect(Kernel).to receive(:p).with("first")
      expect(Kernel).to receive(:p).with("second")
      render_to_document(React.create_element(Foo))
    end
    
    it "should return React::Element for root element" do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component

        def render
          div
        end
      end
      
      expect(Foo.new.render).to be_a(React::Element)
    end
    
    it "should return React::ElementChildrenHandle for inner children" do
      'var inner;'
      
      stub_const 'Foo', Class.new
      Foo.class_eval do
        include React::Component

        def render
          div do
            `inner = #{div {'lorem'}}`
          end
        end
      end
      
      expect(Foo.new.render).to be_a(React::Element)
      expect(`inner`).to be_a(React::ElementChildrenHandle)
    end
  end
end
