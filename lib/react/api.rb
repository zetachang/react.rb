module React
  class API
    @@component_classes = {}

    def self.create_element(type, properties = {}, &block)
      params = []

      # Component Spec or Nomral DOM
      if type.kind_of?(Class)
        raise "Provided class should define `render` method"  if !(type.method_defined? :render)
        @@component_classes[type.to_s] ||= %x{
          React.createClass({
            getInitialState: function(){
              return #{type.respond_to?(:init_state) ? type.init_state.to_n : `{}`};
            },
            componentWillMount: function() {
              instance = #{type.new(`this`)};
              return #{`instance`.component_will_mount if type.method_defined? :component_will_mount};
            },
            componentDidMount: function() {
              instance = #{type.new(`this`)};
              return #{`instance`.component_did_mount if type.method_defined? :component_did_mount};
            },
            render: function() {
              instance = #{type.new(`this`)};
              return #{`instance`.render.to_n};
            }
          })
        }

        params << @@component_classes[type.to_s]
      else
        raise "#{type} not implemented" unless HTML_TAGS.include?(type)
        params << type
      end

      # Passed in properties
      props = `{}`
      properties.map do |key, value|
         if key == "class_name" && value.is_a?(Hash)
           `props[#{lower_camelize(key)}] = React.addons.classSet(#{value.to_n})`
         else
           `props[#{lower_camelize(key)}] = #{value}`
         end
      end
      params << props

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

    private

    def self.lower_camelize(snake_cased_word)
      words = snake_cased_word.split("_")
      result = [words.first]
      result.concat(words[1..-1].map {|word| word[0].upcase + word[1..-1] })
      result.join("")
    end
  end
end
