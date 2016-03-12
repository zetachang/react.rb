require 'spec_helper'

if opal?
  RSpec.describe 'react/test/rspec', type: :component do
    before do
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

    it 'should include react/test in rspec' do
      comp = mount(Greeter)
      expect(component.instance).to eq(comp)
    end

    it 'includes rspec matchers' do
      expect(Greeter).to render(
        '<span>Hello world</span>'
      ).with_params(message: 'world')
    end

    describe 'resetting the session' do
      it 'creates an instance of the mounted component in one example' do
        mount(Greeter)
      end

      it '...then is not availalbe in the next' do
        expect { component.instance }.to raise_error
      end
    end
  end

  RSpec.describe 'react/test/rspec', type: :other do
    before do
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

    it 'should not include react/test in rspec' do
      expect { mount(Greeter) }.to raise_error
    end
  end
end
