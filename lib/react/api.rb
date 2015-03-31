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

    def self.native_component_class(klass)
      klass.class_eval do
        native_alias :componentWillMount, :component_will_mount
        native_alias :componentDidMount, :component_did_mount
        def _render
          self.render.to_n
        end
        native_alias :render, :_render
      end
      %x{
        
        var f = function() { 
          var int = #{klass}.$new.call(#{klass}, arguments[0]); 
          int.state = #{klass.respond_to?(:initial_state) ? klass.initial_state.to_n : `{}`};
          return int;
        };
        f.prototype = #{klass}._alloc.prototype;
        
        Object.assign(f.prototype, React.Component.prototype);
      }
      @@component_classes[klass.to_s] ||= `f`
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
