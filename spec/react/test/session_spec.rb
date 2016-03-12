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
        instance = subject.mount(Greeter, message: 'world')
        expect(instance.params.message).to eq('world')
      end
    end

    describe '#instance' do
      it 'returns the instance of the mounted component' do
        instance = subject.mount(Greeter)
        expect(subject.instance).to eq(instance)
      end
    end

    describe '#element' do
      it 'returns the React::Element for the mounted component' do
        subject.mount(Greeter)
        expect(subject.element).to be_a(React::Element)
      end
    end

    describe '#native' do
      it 'returns the React native instance of the component' do
        instance = subject.mount(Greeter)
        native = instance.instance_variable_get('@native')
        expect(subject.native).to eq(native)
      end
    end

    describe '#update_params' do
      it 'sends new params to the component' do
        instance = subject.mount(Greeter, message: 'world')
        subject.update_params(message: 'moon')
        expect(instance.params.message).to eq('moon')
      end

      it 'leaves unspecified params in tact' do
        instance = subject.mount(Greeter, message: 'world', from: 'outerspace')
        subject.update_params(message: 'moon')
        expect(instance.params.from).to eq('outerspace')
      end

      it 'causes the component to render' do
        instance = subject.mount(Greeter, message: 'world')
        expect(instance).to receive(:render)
        subject.update_params(message: 'moon')
      end
    end

    describe '#force_update' do
      it 'causes the component to render' do
        instance = subject.mount(Greeter)
        expect(instance).to receive(:render)
        subject.force_update!
      end
    end
  end
end
