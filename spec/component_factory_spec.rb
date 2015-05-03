require "spec_helper"

describe React::ComponentFactory do
  describe "native_component_class" do
    it "should bridge the defined life cycle methods" do
      stub_const 'Foo', Class.new
      Foo.class_eval do
        def component_will_mount; end
        def component_did_mount; end
        def component_will_receive_props; end
        def should_component_update?; end
        def component_will_update; end
        def component_did_update; end
        def component_will_unmount; end
      end
      
      ctor = React::ComponentFactory.native_component_class(Foo)
      instance = `new ctor`
      expect(`instance.$component_will_mount`).to be(`instance.componentWillMount`)
      expect(`instance.$component_did_mount`).to be(`instance.componentDidMount`)
      expect(`instance.$component_will_receive_props`).to be(`instance.componentWillReceiveProps`)
      expect(`instance.$should_component_update?`).to be(`instance.shouldComponentUpdate`)
      expect(`instance.$component_will_update`).to be(`instance.componentWillUpdate`)
      expect(`instance.$component_did_update`).to be(`instance.componentDidUpdate`)
      expect(`instance.$component_will_unmount`).to be(`instance.componentWillUnmount`)
      
    end
  end
end
