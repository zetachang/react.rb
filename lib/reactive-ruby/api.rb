module React
  class NativeLibrary
    def self.renames_and_exclusions
      @renames_and_exclusions ||= {}
    end

    def self.libraries
      @libraries ||= []
    end

    def self.const_missing(name)
      if renames_and_exclusions.has_key? name
        if native_name = renames_and_exclusions[name]
          native_name
        else
          super
        end
      else
        libraries.each do |library|
          native_name = "#{library}.#{name}"
          native_component = `eval(#{native_name})` rescue nil
          React::API.import_native_component(name, native_component) and return name if native_component and `native_component != undefined`
        end
        name
      end
    end

    def self.method_missing(n, *args, &block)
      name = n
      if name =~ /_as_node$/
        node_only = true
        name = name.gsub(/_as_node$/, "")
      end
      unless name = const_get(name)
        return super
      end
      if node_only
        React::RenderingContext.build { React::RenderingContext.render(name, *args, &block) }.to_n
      else
        React::RenderingContext.render(name, *args, &block)
      end
    rescue
    end

    def self.imports(library)
      libraries << library
    end

    def self.rename(rename_list={})
      renames_and_exclusions.merge!(rename_list.invert)
    end

    def self.exclude(*exclude_list)
      renames_and_exclusions.merge(Hash[exclude_list.map {|k| [k, nil]}])
    end

  end

  class API
    @@component_classes = {}

    def self.import_native_component(opal_class, native_class)
      @@component_classes[opal_class.to_s] = native_class
    end

    def self.create_native_react_class(type)
      raise "Provided class should define `render` method"  if !(type.method_defined? :render)
      render_fn = (type.method_defined? :_render_wrapper) ? :_render_wrapper : :render
      # this was hashing type.to_s, not sure why but .to_s does not work as it Foo::Bar::View.to_s just returns "View"
      @@component_classes[type] ||= %x{
        React.createClass({
          displayName: #{type.name},
          propTypes: #{type.respond_to?(:prop_types) ? type.prop_types.to_n : `{}`},
          getDefaultProps: function(){
            return #{type.respond_to?(:default_props) ? type.default_props.to_n : `{}`};
          },
          mixins: #{type.respond_to?(:native_mixins) ? type.native_mixins : `[]`},
          statics: #{type.respond_to?(:static_call_backs) ? type.static_call_backs.to_n : `{}`},
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
            return #{`instance`.send(render_fn).to_n};
          }
        })
      }
    end

    def self.create_element(type, properties = {}, &block)
      params = []

      # Component Spec, Normal DOM, String or Native Component
      if @@component_classes[type]
        params << @@component_classes[type]
      elsif type.kind_of?(Class)
        params << create_native_react_class(type)
      elsif HTML_TAGS.include?(type)
        params << type
      elsif type.is_a? String
        return React::Element.new(type)
      else
        raise "#{type} not implemented"
      end

      # Passed in properties
      params << convert_props(properties)

      # Children Nodes
      if block_given?
        children = [yield].flatten.each do |ele|
          params << ele.to_n
        end
      end
      return React::Element.new(`React.createElement.apply(null, #{params})`, type, properties, block)
    end

    def self.clear_component_class_cache
      @@component_classes = {}
    end

    def self.convert_props(properties)
      raise "Component parameters must be a hash. Instead you sent #{properties}" unless properties.is_a? Hash
      props = {}
      properties.map do |key, value|
        if key == "class_name" && value.is_a?(Hash)
          props[lower_camelize(key)] = `React.addons.classSet(#{value.to_n})`
        elsif key == "class"
          props["className"] = value
        elsif ["style", "dangerously_set_inner_HTML"].include? key
          props[lower_camelize(key)] = value.to_n
        else
          props[React::ATTRIBUTES.include?(lower_camelize(key)) ? lower_camelize(key) : key] = value
        end
      end
      props.shallow_to_n
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
