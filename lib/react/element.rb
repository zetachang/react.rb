require 'react/ext/string'

module React
  class Element
    include Native

    alias_native :element_type, :type
    alias_native :props, :props

    attr_reader :type
    attr_reader :properties
    attr_reader :block

    attr_accessor :waiting_on_resources

    def initialize(native_element, type, properties, block)
      @type = type
      @properties = (`typeof #{properties} === 'undefined'` ? nil : properties) || {}
      @block = block
      @native = native_element
    end

    def on(event_name)
      name = event_name.to_s.event_camelize
      props = if React::Event::BUILT_IN_EVENTS.include?("on#{name}")
        {"on#{name}" => %x{
          function(event){
            #{yield React::Event.new(`event`)}
          }
        }}
      else
        {"_on#{name}" => %x{
          function(){
            #{yield *Array(`arguments`)}
          }
        }}
      end
      @native = `React.cloneElement(#{self.to_n}, #{props.to_n})`
      @properties.merge! props
      self
    end

    def render(props = {})  # for rendering children
      if props.empty?
        React::RenderingContext.render(self)
      else
        React::RenderingContext.render(
          Element.new(
            `React.cloneElement(#{self.to_n}, #{API.convert_props(props)})`,
            type,
            properties.merge(props),
            block
          )
        )
      end
    end

    def method_missing(class_name, args = {}, &new_block)
      class_name = class_name.split("__").collect { |s| s.gsub("_", "-") }.join("_")
      new_props = properties.dup
      new_props["class"] = "#{new_props['class']} #{class_name} #{args.delete("class")} #{args.delete('className')}".split(" ").uniq.join(" ")
      new_props.merge! args
      React::RenderingContext.replace(
        self,
        React::RenderingContext.build { React::RenderingContext.render(type, new_props, &new_block) }
      )
    end

    def as_node
      React::RenderingContext.as_node(self)
    end

    def delete
      React::RenderingContext.delete(self)
    end
  end
end
