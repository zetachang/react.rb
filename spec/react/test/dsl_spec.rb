require 'spec_helper'

if opal?
  RSpec.describe React::Test::DSL do
    describe 'the DSL' do
      let(:session) { Class.new { include React::Test::DSL }.new }

      before do
        React::Test.reset_session!

        stub_const 'Greeter', Class.new
        Greeter.class_eval do
          include React::Component

          params do
            optional :message
            optional :from
          end

          def render
            span { "Hello #{params.message}" }
          end
        end
      end

      it 'is possible to include it in another class' do
        session.mount(Greeter)
        expect(session.instance).to be_a(Greeter)
      end

      it "should provide a 'component' shortcut for more expressive tests" do
        session.component.mount(Greeter)
        expect(session.component.instance).to be_a(Greeter)
      end

      React::Test::Session::DSL_METHODS.each do |method|
        it "responds to all DSL method: #{method}" do
          expect(session).to respond_to(method)
        end
      end
    end
  end
end
