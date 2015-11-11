require 'spec_helper'

if opal?
describe React::Callbacks do
  it 'defines callback' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      before_dinner :wash_hand

      def wash_hand
      end
    end

    expect_any_instance_of(Foo).to receive(:wash_hand)
    Foo.new.run_callback(:before_dinner)
  end

  it 'defines multiple callbacks' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner

      before_dinner :wash_hand, :turn_of_laptop

      def wash_hand;end

      def turn_of_laptop;end
    end

    expect_any_instance_of(Foo).to receive(:wash_hand)
    expect_any_instance_of(Foo).to receive(:turn_of_laptop)
    Foo.new.run_callback(:before_dinner)
  end

  it 'defines block callback' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      attr_accessor :a
      attr_accessor :b

      define_callback :before_dinner

      before_dinner do
        self.a = 10
      end
      before_dinner do
        self.b = 20
      end
    end

    foo = Foo.new
    foo.run_callback(:before_dinner)
    expect(foo.a).to eq(10)
    expect(foo.b).to eq(20)
  end

  it 'defines multiple callback group' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      define_callback :after_dinner
      attr_accessor :a

      before_dinner do
        self.a = 10
      end
    end

    foo = Foo.new
    foo.run_callback(:before_dinner)
    foo.run_callback(:after_dinner)

    expect(foo.a).to eq(10)
  end

  it 'receives args as callback' do
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      define_callback :after_dinner

      attr_accessor :lorem

      before_dinner do |a, b|
        self.lorem  = "#{a}-#{b}"
      end

      after_dinner :eat_ice_cream
      def eat_ice_cream(a,b,c);  end
    end

    expect_any_instance_of(Foo).to receive(:eat_ice_cream).with(4,5,6)

    foo = Foo.new
    foo.run_callback(:before_dinner, 1, 2)
    foo.run_callback(:after_dinner, 4, 5, 6)
    expect(foo.lorem).to eq('1-2')
  end
end
end
