require 'spec_helper'

if opal?
  RSpec.describe React::Test::Session do
    subject { described_class.new }
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

    describe '#mount' do
      it 'returns an instance of the mounted component' do
        expect(subject.mount(Greeter)).to be_a(Greeter)
      end

      it 'actualy mounts the component' do
        expect(subject.mount(Greeter)).to be_mounted
      end

      it 'optionaly passes params to the component' do
        component = subject.mount(Greeter, message: 'world')
        expect(component.params.message).to eq('world')
      end
    end

    describe '#component' do
      it 'returns the instance of the mounted component' do
        component = subject.mount(Greeter)
        expect(subject.component).to eq(component)
      end
    end

    describe '#element' do
      it 'returns the React::Element for the mounted component' do
        subject.mount(Greeter)
        expect(subject.element).to be_a(React::Element)
      end
    end

    describe '#instance' do
      it 'returns the React native instance of the component' do
        component = subject.mount(Greeter)
        native = component.instance_variable_get('@native')
        expect(subject.instance).to eq(native)
      end
    end

    describe '#update_params' do
      it 'sends new params to the component' do
        component = subject.mount(Greeter, message: 'world')
        subject.update_params(message: 'moon')
        expect(component.params.message).to eq('moon')
      end

      it 'leaves unspecified params in tact' do
        component = subject.mount(Greeter, message: 'world', from: 'outerspace')
        subject.update_params(message: 'moon')
        expect(component.params.from).to eq('outerspace')
      end

    describe '#force_update' do
      it 'causes the component to render' do
        component = subject.mount(Greeter)
        expect(component).to receive(:render)
        subject.force_update!
      end
    end
  end
end
