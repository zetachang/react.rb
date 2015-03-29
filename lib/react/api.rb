module React
  class API
    @@component_classes = {}

    def self.create_element(type, properties = {}, &block)
      params = []

      # Component Spec or Nomral DOM
      if type.kind_of?(Class)
        raise "Provided class should define `render` method"  if !(type.method_defined? :render)
        params << self.native_component_class(type)
      else
        raise "#{type} not implemented" unless HTML_TAGS.include?(type)
        params << type
      end

      # Passed in properties
      props = {}
      properties.map do |key, value|
         if key == "class_name" && value.is_a?(Hash)
           props[lower_camelize(key)] = value.inject([]) {|ary, (k,v)| v ? ary.push(k) : ary}.join(" ")
         else
           props[React::ATTRIBUTES.include?(lower_camelize(key)) ? lower_camelize(key) : key] = value
         end
      end
      params << props.shallow_to_n

      # Children Nodes
      if block_given?
        children = [yield].flatten.each do |ele|
          params << ele.to_n
        end
      end

      return React::Element.new(`React.createElement.apply(null, #{params})`)
    end

    def self.clear_component_class_cache
      @@component_classes = {}
    end

    def self.native_component_class(type)
      @@component_classes[type.to_s] ||= %x{
        React.createClass({
          propTypes: #{type.respond_to?(:prop_types) ? type.prop_types.to_n : `{}`},
          getDefaultProps: function(){
            return #{type.respond_to?(:default_props) ? type.default_props.to_n : `{}`};
          },
          getInitialState: function(){
            return #{type.respond_to?(:initial_state) ? type.initial_state.to_n : `{}`};
          },
          componentWillMount: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_mount if type.method_defined? :component_will_mount};
          },
          componentDidMount: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_did_mount if type.method_defined? :component_did_mount};
          },
          componentWillReceiveProps: function(next_props) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_receive_props(`next_props`) if type.method_defined? :component_will_receive_props};
          },
          shouldComponentUpdate: function(next_props, next_state) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.should_component_update?(`next_props`, `next_state`) if type.method_defined? :should_component_update?};
          },
          componentWillUpdate: function(next_props, next_state) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_update(`next_props`, `next_state`) if type.method_defined? :component_will_update};
          },
          componentDidUpdate: function(prev_props, prev_state) {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_did_update(`prev_props`, `prev_state`) if type.method_defined? :component_did_update};
          },
          componentWillUnmount: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.component_will_unmount if type.method_defined? :component_will_unmount};
          },
          _getOpalInstance: function() {
            if (this.__opalInstance == undefined) {
              var instance = #{type.new(`this`)};
            } else {
              var instance = this.__opalInstance;
            }
            this.__opalInstance = instance;
            return instance;
          },
          render: function() {
            var instance = this._getOpalInstance.apply(this);
            return #{`instance`.render.to_n};
          }
        })
      }
    end

    private

    def self.lower_camelize(snake_cased_word)
      words = snake_cased_word.split("_")
      result = [words.first]
      result.concat(words[1..-1].map {|word| word[0].upcase + word[1..-1] })
      result.join("")
    end
  end
end
