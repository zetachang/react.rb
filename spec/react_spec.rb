require "spec_helper"

describe React do
  after(:each) do
    React::API.clear_component_class_cache
  end

  describe "is_valid_element" do
    it "should return true if passed a valid element" do
      element = React::Element.new(`React.createElement('div')`)
      expect(React.is_valid_element(element)).to eq(true)
    end

    it "should return false is passed a non React element" do
      element = React::Element.new(`{}`)
      expect(React.is_valid_element(element)).to eq(false)
    end
  end

  describe "create_element" do
    it "should create a valid element with only tag" do
      element = React.create_element('div')
      expect(React.is_valid_element(element)).to eq(true)
    end

    context "with block" do
      it "should create a valid element with text as only child when block yield String" do
        element = React.create_element('div') { "lorem ipsum" }
        expect(React.is_valid_element(element)).to eq(true)
        expect(element.props.children).to eq("lorem ipsum")
      end

      it "should create a valid element with children as array when block yield Array of element" do
        element = React.create_element('div') do
          [React.create_element('span'), React.create_element('span'), React.create_element('span')]
        end
        expect(React.is_valid_element(element)).to eq(true)
        expect(element.props.children.length).to eq(3)
      end

      it "should render element with children as array when block yield Array of element" do
        element = React.create_element('div') do
          [React.create_element('span'), React.create_element('span'), React.create_element('span')]
        end
        instance = renderElementToDocument(element)
        expect(instance.getDOMNode.childNodes.length).to eq(3)
      end
    end
    describe "custom element" do
      before do
        stub_const 'Foo', Class.new
        Foo.class_eval do
          def render
            React.create_element("div") { "lorem" }
          end
        end
      end

      it "should render element with only one children correctly" do
        element = React.create_element(Foo) { React.create_element('span') }
        instance = renderElementToDocument(element)
        expect(instance.props.children).not_to be_a(Array)
        expect(instance.props.children.type).to eq("span")
      end

      it "should render element with more than one children correctly" do
        element = React.create_element(Foo) { [React.create_element('span'), React.create_element('span')] }
        instance = renderElementToDocument(element)
        expect(instance.props.children).to be_a(Array)
        expect(instance.props.children.length).to eq(2)
      end

      it "should create a valid element provided class defined `render`" do
        element = React.create_element(Foo)
        expect(React.is_valid_element(element)).to eq(true)
      end

      it "should allow creating with properties" do
        element = React.create_element(Foo, foo: "bar")
        expect(element.props.foo).to eq("bar")
      end

      it "should raise error if provided class doesn't defined `render`" do
        expect { React.create_element(Array) }.to raise_error
      end

      it "should use the same instance for the same ReactComponent" do
        Foo.class_eval do
          attr_accessor :a
          def initialize(n)
            self.a = 10
          end

          def component_will_mount
            self.a = 20
          end

          def render
            React.create_element("div") { self.a.to_s }
          end
        end

        expect(React.render_to_static_markup(React.create_element(Foo))).to eq("<div>20</div>")
      end

      it "should match the instance cycle to ReactComponent life cycle" do
        `var count = 0;`

        Foo.class_eval do
          def initialize
            `count = count + 1;`
          end
          def render
            React.create_element("div")
          end
        end

        renderToDocument(Foo)
        renderToDocument(Foo)

        expect(`count`).to eq(2)
      end
    end

    describe "create element with properties" do
      it "should enforce snake-cased property name" do
        element = React.create_element("div", class_name: "foo")
        expect(element.props.className).to eq("foo")
      end

      it "should allow custom property" do
        element = React.create_element("div", foo: "bar")
        expect(element.props.foo).to eq("bar")
      end

      it "should not camel-case custom property" do
        element = React.create_element("div", foo_bar: "foo")
        expect(element.props.foo_bar).to eq("foo")
      end
    end

    describe "class_name helpers (React.addons.classSet)" do
      it "should transform Hash provided to `class_name` props as string" do
        classes = {foo: true, bar: false, lorem: true}
        element = React.create_element("div", class_name: classes)

        expect(element.props.className).to eq("foo lorem")
      end

      it "should not alter behavior when passing a string" do
        element = React.create_element("div", class_name: "foo bar")

        expect(element.props.className).to eq("foo bar")
      end
    end
  end


  describe "render" do
    async "should render element to DOM" do
      div = `document.createElement("div")`
      React.render(React.create_element('span') { "lorem" }, div) do
        run_async {
          expect(`div.children[0].tagName`).to eq("SPAN")
          expect(`div.textContent`).to eq("lorem")
        }
      end
    end

    it "should work without providing a block" do
      div = `document.createElement("div")`
      React.render(React.create_element('span') { "lorem" }, div)
    end

    it "should return a React::Component::API compatible object" do
      div = `document.createElement("div")`
      component = React.render(React.create_element('span') { "lorem" }, div)
      React::Component::API.public_instance_methods(true).each do |method_name|
        expect(component).to respond_to(method_name)
      end
    end

    pending "should return nil to prevent abstraction leakage" do
      div = `document.createElement("div")`
      expect {
        React.render(React.create_element('span') { "lorem" }, div)
      }.to be_nil
    end
  end

  describe "render_to_string" do
    it "should render a React.Element to string" do
      ele = React.create_element('span') { "lorem" }
      expect(React.render_to_string(ele)).to be_kind_of(String)
    end
  end

  describe "unmount_component_at_node" do
    async "should unmount component at node" do
      div = `document.createElement("div")`
      React.render(React.create_element('span') { "lorem" }, div ) do
        run_async {
          expect(React.unmount_component_at_node(div)).to eq(true)
        }
      end
    end
  end

end
