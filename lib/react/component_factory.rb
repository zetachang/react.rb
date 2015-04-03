module React
  class ComponentFactory
    @@component_classes = {}

    def self.clear_component_class_cache
      @@component_classes = {}
    end

    def self.native_component_class(klass)
      klass.class_eval do
        native_alias :componentWillMount, :component_will_mount
        native_alias :componentDidMount, :component_did_mount
        native_alias :render, :render
      end
      %x{
        function ctor(){
          this.constructor = ctor; 
          this.state = #{klass.respond_to?(:initial_state) ? klass.initial_state.to_n : `{}`};
          React.Component.apply(this, arguments);
          #{klass}._alloc.prototype.$initialize.call(this);
        };
        ctor.prototype = klass._proto;
        Object.assign(ctor.prototype, React.Component.prototype);    
        ctor.propTypes = #{klass.respond_to?(:prop_types) ? klass.prop_types.to_n : `{}`};
        ctor.defaultProps = #{klass.respond_to?(:default_props) ? klass.default_props.to_n : `{}`};
      }
      @@component_classes[klass.to_s] ||= `ctor`
    end
  end
end
