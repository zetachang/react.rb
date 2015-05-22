require "spec_helper"

describe React do
  describe "is_valid_element" do
    it "should return true if passed a valid element" do
      element = `React.createElement('div')`
      expect(React.is_valid_element(element)).to eq(true)
    end

    it "should return false is passed a non React element" do
      element = `{}`
      expect(React.is_valid_element(element)).to eq(false)
    end
  end

  describe "create_element" do
    it "should create a valid element with only tag" do
      element = React.create_element('div')
      expect(React.is_valid_element(element)).to eq(true)
    end

    it "should allow passed a React.Component class (constructor function)" do
      hello_message = `React.createClass({displayName: "HelloMessage",
        render: function() {
            return React.createElement("div", null, "Hello ", this.props.name);
        }
      });`
      element = React.create_element(hello_message, name: "David")
      expect(React.render_to_static_markup(element)).to eq('<div>Hello David</div>')
    end

    context "with block" do
      it "should create a valid element with text as only child when block yield String" do
        element = React.create_element('div') { "lorem ipsum" }
        expect(React.is_valid_element(element)).to eq(true)
        expect(element.children.to_a).to eq(["lorem ipsum"])
      end

      it "should create a valid element with children as array when block yield Array of element" do
        element = React.create_element('div') do
          [React.create_element('span'), React.create_element('span'), React.create_element('span')]
        end
        expect(React.is_valid_element(element)).to eq(true)
        expect(element.children.length).to eq(3)
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

      it "should create element with only one children correctly" do
        element = React.create_element(Foo) { React.create_element('span') }
        expect(element.children.count).to eq(1)
        expect(element.children.map{|e| e.element_type }).to eq(["span"])
      end

      it "should create element with more than one children correctly" do
        element = React.create_element(Foo) { [React.create_element('span'), React.create_element('span')] }
        expect(element.children.count).to eq(2)
        expect(element.children.map{|e| e.element_type }).to eq(["span", "span"])
      end

      it "should create a valid element provided class defined `render`" do
        element = React.create_element(Foo)
        expect(React.is_valid_element(element)).to eq(true)
      end

      it "should allow creating with properties" do
        element = React.create_element(Foo, foo: "bar")
        expect(element.props[:foo]).to eq("bar")
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

        render_to_document(React.create_element(Foo))
        render_to_document(React.create_element(Foo))

        expect(`count`).to eq(2)
      end
    end

    describe "create element with properties" do
      it "should enforce snake-cased property name" do
        element = React.create_element("div", class_name: "foo")
        expect(element.props[:className]).to eq("foo")
      end

      it "should allow custom property" do
        element = React.create_element("div", foo: "bar")
        expect(element.props[:foo]).to eq("bar")
      end

      it "should camel-case all property" do
        element = React.create_element("div", foo_bar: "foo", class_name: 'fancy')
        expect(element.props[:fooBar]).to eq("foo")
        expect(element.props[:className]).to eq("fancy")
      end
    end

    describe "class_name helpers (React.addons.classSet)" do
      it "should transform Hash provided to `class_name` props as string" do
        classes = {foo: true, bar: false, lorem: true}
        element = React.create_element("div", class_name: classes)

        expect(element.props[:className]).to eq("foo lorem")
      end

      it "should not alter behavior when passing a string" do
        element = React.create_element("div", class_name: "foo bar")

        expect(element.props[:className]).to eq("foo bar")
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

  def get_dom_node(react_element)
    rendered_element = `React.addons.TestUtils.renderIntoDocument(#{react_element})`
    React.find_dom_node rendered_element
  end

  def get_jq_node(react_element)
    dom_node = get_dom_node react_element
    dom_node ? Element.find(dom_node) : nil
  end

  def find_element_jq_node(react_element, element_type)
    jq_dom_node = get_jq_node react_element
    return nil unless jq_dom_node
    elements = jq_dom_node.find(element_type)
    elements.any? ? elements : nil
  end
  
  def change_value_in_element_select(element, value)
    rendered = `React.addons.TestUtils.renderIntoDocument(#{element})`          
    parent_node = React.find_dom_node rendered
    select = Element.find(parent_node).find('select')
    select_native = select.get()[0]         
    `React.addons.TestUtils.Simulate.change(#{select_native}, {target: {value: #{value}}})`
  end
  
  RSpec::Matchers.define :contain_dom_element do |element_type|
     match do |react_element|
       @element = find_element_jq_node react_element, element_type
       next false unless @element
       # Don't make the test get the type exactly right
       @element.value.to_s == @expected_value.to_s
     end

     failure_message do |react_element|
       if @element
         "Found select, but value was '#{@element.value}' and we expected '#{@expected_value}'"
       else
         "Expected rendered element to contain a #{element_type}, but it did not, did contain this: #{Native(get_dom_node(react_element)).outerHTML}"
       end
     end

     chain :with_selected_value do |expected_value|
       @expected_value = expected_value
     end
   end

  describe 'value_link' do    
    subject(:element) {
      React.create_element('div') do
        React.create_element('select', id: 'the_select_box', value_link: value_link) do
          [React.create_element('option', value: '2') {'first choice'}, React.create_element('option', value: '3') {'second choice'}]
        end
      end
    }
    
    context 'via method' do      
      let(:actual_value) { {} }
      let(:value_link) { method_value_link }
      
      def req_change_via_method(new_value)
        actual_value[:set] = new_value
      end
      
      def method_value_link
        do_it = lambda do |new_value|
          req_change_via_method new_value
        end
        return 3, do_it
      end        

      it { is_expected.to contain_dom_element(:select).with_selected_value(3) }       
      
      describe 'after change' do
        before do
          change_value_in_element_select element, '2'
        end
        
        subject { actual_value[:set] }
        
        it { is_expected.to eq '2' }
      end      
    end        
  end
end
