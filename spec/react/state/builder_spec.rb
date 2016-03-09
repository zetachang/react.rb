require 'spec_helper'

if opal?

  module React
    class ObservedValue

    end
  end
  describe React::ObservedValue do
    xit 'delegates missing methods to the given object' do
      value = instance_double(String)
      expect(value).to receive(:non_existant_method)

    end
  end

  module React
    class State
      class Builder
        def define(name, *args, &block)
          options = args.extract_options!
          klass = args.first == :class # || options[:class]
          initial = block || Proc.new { options[:initial] }
          class_rules[name] = initial if klass
          instance_rules[name] = initial unless klass
        end

        def class_rules
          @class_rules ||= {}
        end

        def instance_rules
          @instance_rules ||= {}
        end

        def build_instance_proxy(proxy)
          instance_rules.each do |rule, value|
            build_proxy(proxy, rule, value)
          end
        end

        def build_class_proxy(proxy)
          class_rules.each do |rule, value|
            build_proxy(proxy, rule, value)
          end
        end

        private

        def build_proxy(proxy, rule, value)
          @var = 'huh'
          proxy.instance_variable_set('@var', 'ff')
          proxy.define_singleton_method(rule) do
#             value.call
            Observable.new(value.call) do |new_val|
              # ask component for render
            end
            value.call
          end
          proxy.define_singleton_method("#{rule}=") do
              # ask component for render
          end
        end
      end
    end
  end

  describe React::State::Builder do
    let(:proxy) { Object.new }
    subject(:builder) { described_class.new }

    describe 'instance state' do
      it 'defines a getter method on the instance proxy' do
        builder.define(:foo)
        builder.build_instance_proxy(proxy)
        expect(proxy).to respond_to(:foo)
      end

      it 'defines a setter method on the instance proxy' do
        builder.define(:foo)
        builder.build_instance_proxy(proxy)
        expect(proxy).to respond_to(:foo=)
      end

      it 'does not define methods on the class proxy' do
        builder.define(:foo)
        builder.build_class_proxy(proxy)
        expect(proxy).to_not respond_to(:foo)
        expect(proxy).to_not respond_to(:foo=)
      end

      it 'has a default value of nil' do
        builder.define(:foo)
        builder.build_instance_proxy(proxy)
        expect(proxy.foo).to be_nil
      end
    end

    describe 'class state' do
      it 'defines a getter method on the class proxy' do
        builder.define(:foo, :class)
        builder.build_class_proxy(proxy)
        expect(proxy).to respond_to(:foo)
      end

      it 'defines a setter method on the class proxy' do
        builder.define(:foo, :class)
        builder.build_class_proxy(proxy)
        expect(proxy).to respond_to(:foo=)
      end

      it 'does not define methods on the instance proxy' do
        builder.define(:foo, :class)
        builder.build_instance_proxy(proxy)
        expect(proxy).to_not respond_to(:foo)
        expect(proxy).to_not respond_to(:foo=)
      end
    end

    describe 'initial value' do
      %i[class instance].each do |type|
        it "sets a default initial value of nil for #{type} state" do
          klass = type == :class ? :class : nil
          builder.define(:foo, klass)
          builder.send("build_#{type}_proxy", proxy)
          expect(proxy.foo).to be_nil
        end

        it "takes an initial value option for #{type} state" do
          klass = type == :class ? :class : nil
          builder.define(:foo, klass, initial: 'Bar')
          builder.send("build_#{type}_proxy", proxy)
          expect(proxy.foo).to eq('Bar')
        end

        it "takes an initial value as a block for #{type} state" do
          klass = type == :class ? :class : nil
          builder.define(:foo, klass) do
            'Foo Bar'
          end
          builder.send("build_#{type}_proxy", proxy)
          expect(proxy.foo).to eq('Foo Bar')
        end
      end
    end
  end
end
