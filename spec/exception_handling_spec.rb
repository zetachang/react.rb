describe "displaying helpful warning and error messages" do
  
  before(:all) do
    %x{
      window.old_error_console = console.error
      console.error = function(m) { window.last_error_message = m; }
    }
  end
  
  after(:all) do
    %x{
      console.error = window.old_error_console
    }
  end

  it "should print and exception message" do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Component
      def render
        raise "error happened"
      end
    end
    React.render_to_static_markup(React.create_element(Foo)) 
    expect(`window.last_error_message`).to include("error happened")
  end
  
end