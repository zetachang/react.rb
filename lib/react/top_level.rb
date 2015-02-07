require "native"
require 'active_support'
require "promise"

module React  
  HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo big blockquote body br
                button canvas caption cite code col colgroup data datalist dd del details dfn
                dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
                h6 head header hr html i iframe img input ins kbd keygen label legend li link
                main map mark menu menuitem meta meter nav noscript object ol optgroup option
                output p param picture pre progress q rp rt ruby s samp script section select
                small source span strong style sub summary sup table tbody td textarea tfoot th
                thead time title tr track u ul var video wbr)
  def self.create_element(type)
    if type.kind_of?(Class)
      raise "Provided class should define `render` method"  if !(type.method_defined? :render)
      @instance = type.new
      spec = %x{
        {
          componentWillMount: function() {
            #{@instance._bridge_object = `this`}
            #{@instance._component_will_mount()}
          },
          componentDidMount: function() {
            #{@instance._bridge_object = `this`}
            #{@instance._component_did_mount()}
          },
          render: function() {
            return #{@instance.render.to_n}
          }
        };
      }
      
      if @instance.respond_to?("_init_state") && state = @instance._init_state
        %x{ 
          spec.getInitialState = function() {
            return #{state.to_n};
          }
        }
      end
      
      `var componentClass = React.createClass(spec)`
      return React::Element.new(`React.createElement(componentClass)`)
    else
      if HTML_TAGS.include?(type)
        if block_given?
          React::Element.new(`React.createElement(#{type}, null, #{yield})`)
        else
          React::Element.new(`React.createElement(#{type})`)
        end
      else
        raise "not implemented"
      end
    end
  end
  
  def self.render(element, container)
    if block_given?
      %x{ 
        React.render(#{element.to_n}, container, function(){#{ yield }}) 
      }
    else
      `React.render(#{element.to_n}, container, function(){})`
    end
    return nil
  end
  
  def self.is_valid_element(element)
    element.kind_of?(React::Element) && `React.isValidElement(#{element.to_n})`
  end
  
  def self.render_to_string(element)
    `React.renderToString(#{element.to_n})`
  end
end