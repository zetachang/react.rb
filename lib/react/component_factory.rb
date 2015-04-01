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
        
        var f = function() { 
          var int = #{klass}.$new.call(#{klass}, arguments[0]); 
          int.state = #{klass.respond_to?(:initial_state) ? klass.initial_state.to_n : `{}`};
          return int;
        };
        f.prototype = #{klass}._alloc.prototype;
        f.propTypes = #{klass.respond_to?(:prop_types) ? klass.prop_types.to_n : `{}`};
        f.defaultProps = #{klass.respond_to?(:default_props) ? klass.default_props.to_n : `{}`};    
        Object.assign(f.prototype, React.Component.prototype);
      }
      @@component_classes[klass.to_s] ||= `f`
    end
  end
end
