require "spec_helper"
require "react/callbacks"

describe React::Callbacks do
  it "should be able to define callback" do
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

  it "should be able to define multiple callbacks" do
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

  it "should be able to define block callback" do
    stub_const 'Foo', Class.new
    proc_a = Proc.new {}
    proc_b = Proc.new {}
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner

      before_dinner(&proc_a)
      before_dinner(&proc_b)
    end

    expect(proc_a).to receive(:call)
    expect(proc_b).to receive(:call)
    Foo.new.run_callback(:before_dinner)
  end

  it "should be able to define multiple callback group" do
    proc_a = Proc.new {}
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      define_callback :after_dinner

      before_dinner(&proc_a)
    end

    expect(proc_a).to receive(:call)
    Foo.new.run_callback(:before_dinner)
    Foo.new.run_callback(:after_dinner)
  end

  it "should be able to receive args as callback" do
    a_proc = Proc.new { }
    stub_const 'Foo', Class.new
    Foo.class_eval do
      include React::Callbacks
      define_callback :before_dinner
      define_callback :after_dinner

      before_dinner(&a_proc)
      after_dinner :eat_ice_cream
      def eat_ice_cream(a,b,c);  end
    end

    expect(a_proc).to receive(:call).with(1,2)
    expect_any_instance_of(Foo).to receive(:eat_ice_cream).with(4,5,6)

    Foo.new.run_callback(:before_dinner, 1, 2)
    Foo.new.run_callback(:after_dinner, 4, 5, 6)
  end
end
