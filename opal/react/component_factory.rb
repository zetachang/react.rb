module React
  class ComponentFactory
    @@component_classes = {}

    def self.clear_component_class_cache
      @@component_classes = {}
    end

    def self.native_component_class(klass)
      klass.class_eval do
        include(React::Component::API)
        # In Opal 0.8, native_alias fails if the method isn't there but we don't want to force all of these to be implemented
        optional_native_alias = lambda do |js, ruby|
          not_there = `!(#{self}.$$proto['$' + #{ruby}])`
          native_alias js, ruby unless not_there
        end
        optional_native_alias[:componentWillMount, :component_will_mount]
        optional_native_alias[:componentDidMount, :component_did_mount]
        optional_native_alias[:componentWillReceiveProps, :component_will_receive_props]
        optional_native_alias[:shouldComponentUpdate, :should_component_update?]
        optional_native_alias[:componentWillUpdate, :component_will_update]
        optional_native_alias[:componentDidUpdate, :component_did_update]
        optional_native_alias[:componentWillUnmount, :component_will_unmount]
        native_alias :render, :render
        optional_native_alias[:render, :_render_wrapper]
      end
      %x{
        if (!Object.assign) {
          Object.defineProperty(Object, 'assign', {
            enumerable: false,
            configurable: true,
            writable: true,
            value: function(target, firstSource) {
              'use strict';
              if (target === undefined || target === null) {
                throw new TypeError('Cannot convert first argument to object');
              }

              var to = Object(target);
              for (var i = 1; i < arguments.length; i++) {
                var nextSource = arguments[i];
                if (nextSource === undefined || nextSource === null) {
                  continue;
                }

                var keysArray = Object.keys(Object(nextSource));
                for (var nextIndex = 0, len = keysArray.length; nextIndex < len; nextIndex++) {
                  var nextKey = keysArray[nextIndex];
                  var desc = Object.getOwnPropertyDescriptor(nextSource, nextKey);
                  if (desc !== undefined && desc.enumerable) {
                    to[nextKey] = nextSource[nextKey];
                  }
                }
              }
              return to;
            }
          });
        }
        function ctor(props){
          this.constructor = ctor; 
          this.state = #{klass.respond_to?(:initial_state) ? klass.initial_state.to_n : `{}`};
          React.Component.apply(this, arguments);
          #{klass}.$$alloc.prototype.$initialize.call(this, Opal.Hash.$new(props));
        };
        ctor.prototype = klass.$$proto;
        Object.assign(ctor.prototype, React.Component.prototype);    
        ctor.propTypes = #{klass.respond_to?(:prop_types) ? klass.prop_types.to_n : `{}`};
        ctor.defaultProps = #{klass.respond_to?(:default_props) ? klass.default_props.to_n : `{}`};
      }
      @@component_classes[klass.to_s] ||= `ctor`
    end
  end
end
