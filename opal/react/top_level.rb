require "native"
require 'active_support'
require "react/ext/string"

module React
  HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo big blockquote body br
                button canvas caption cite code col colgroup data datalist dd del details dfn
                dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
                h6 head header hr html i iframe img input ins kbd keygen label legend li link
                main map mark menu menuitem meta meter nav noscript object ol optgroup option
                output p param picture pre progress q rp rt ruby s samp script section select
                small source span strong style sub summary sup table tbody td textarea tfoot th
                thead time title tr track u ul var video wbr)

  def self.create_element(type, properties = {}, &block)
    params = []
    
    # Component Spec or Nomral DOM
    params << if `(typeof type === 'function')`
      type
    elsif type.kind_of?(Class)
      raise "Provided class should define `render` method"  if !(type.method_defined? :render)
      React::ComponentFactory.native_component_class(type)
    else
      raise "#{type} not implemented" unless HTML_TAGS.include?(type)
      type
    end

    # Passed in properties
    props = properties.map do |key, value|
      new_key = key.lower_camelize
      new_value = if key == "class_name" && value.is_a?(Hash)
        value.inject([]) {|ary, (k,v)| v ? ary.push(k) : ary}.join(" ")
      elsif key == 'value_link'
        process_value_link value
      else
        value
      end
      [new_key, new_value]
    end    
    
    params << Hash[props].shallow_to_n

    # Children Nodes
    if block_given?
      children = [yield].flatten.each do |ele|
        params << ele
      end
    end

    return `React.createElement.apply(null, #{params})`
  end
  
  def self.process_value_link(arguments)
    arguments = arguments.call if arguments.is_a? Proc
    {value: arguments[:value], requestChange: arguments[:request_change]}.to_n
  end

  def self.render(element, container)
    component = Native(`React.render(#{element}, container, function(){#{yield if block_given?}})`)
    component.class.include(React::Component::API)
    component
  end

  def self.is_valid_element(element)
    `React.isValidElement(#{element})`
  end

  def self.render_to_string(element)
    `React.renderToString(#{element})`
  end

  def self.render_to_static_markup(element)
    `React.renderToStaticMarkup(#{element})`
  end

  def self.unmount_component_at_node(node)
    `React.unmountComponentAtNode(node)`
  end

  def self.expose_native_class(*args)
    args.each do |klass|
      `window[#{klass.to_s}] = #{React::ComponentFactory.native_component_class(klass)}`
    end
  end
  
  def self.find_dom_node(component)
    `React.findDOMNode(component)`
  end
end
