require "native"
require 'active_support'
require 'react/component/base'

module React
  HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo big blockquote body br
                button canvas caption cite code col colgroup data datalist dd del details dfn
                dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
                h6 head header hr html i iframe img input ins kbd keygen label legend li link
                main map mark menu menuitem meta meter nav noscript object ol optgroup option
                output p param picture pre progress q rp rt ruby s samp script section select
                small source span strong style sub summary sup table tbody td textarea tfoot th
                thead time title tr track u ul var video wbr) +
             # The SVG Tags
             %w(circle clipPath defs ellipse g line linearGradient mask path pattern polygon polyline
                radialGradient rect stop svg text tspan)
  ATTRIBUTES = %w(accept acceptCharset accessKey action allowFullScreen allowTransparency alt
                async autoComplete autoPlay cellPadding cellSpacing charSet checked classID
                className cols colSpan content contentEditable contextMenu controls coords
                crossOrigin data dateTime defer dir disabled download draggable encType form
                formAction formEncType formMethod formNoValidate formTarget frameBorder height
                hidden href hrefLang htmlFor httpEquiv icon id label lang list loop manifest
                marginHeight marginWidth max maxLength media mediaGroup method min multiple
                muted name noValidate open pattern placeholder poster preload radioGroup
                readOnly rel required role rows rowSpan sandbox scope scrolling seamless
                selected shape size sizes span spellCheck src srcDoc srcSet start step style
                tabIndex target title type useMap value width wmode dangerouslySetInnerHTML) +
                #SVG ATTRIBUTES
                %w(clipPath cx cy d dx dy fill fillOpacity fontFamily
                fontSize fx fy gradientTransform gradientUnits markerEnd
                markerMid markerStart offset opacity patternContentUnits
                patternUnits points preserveAspectRatio r rx ry spreadMethod
                stopColor stopOpacity stroke  strokeDasharray strokeLinecap
                strokeOpacity strokeWidth textAnchor transform version
                viewBox x1 x2 x xlinkActuate xlinkArcrole xlinkHref xlinkRole
                xlinkShow xlinkTitle xlinkType xmlBase xmlLang xmlSpace y1 y2 y)

  def self.html_tags?(name)
    tags = HTML_TAGS
    `
    for(var i = 0; i < tags.length; i++){
      if(tags[i] === name)
        return true;
    }
    return false;
    `
  end

  def self.html_attrs?(name)
    attrs = ATTRIBUTES
    `
    for(var i = 0; i < attrs.length; i++){
      if(attrs[i] === name)
        return true;
    }
    return false;
    `
  end

  def self.create_element(type, properties = {}, &block)
    React::API.create_element(type, properties, &block)
  end

  def self.render(element, container)
    container = `container.$$class ? container[0] : container`
    component = Native(`React.render(#{element.to_n}, container, function(){#{yield if block_given?}})`)
    component.class.include(React::Component::API)
    component
  end

  def self.is_valid_element(element)
    element.kind_of?(React::Element) && `React.isValidElement(#{element.to_n})`
  end

  def self.render_to_string(element)
    React::RenderingContext.build { `React.renderToString(#{element.to_n})` }
  end

  def self.render_to_static_markup(element)
    React::RenderingContext.build { `React.renderToStaticMarkup(#{element.to_n})` }
  end

  def self.unmount_component_at_node(node)
    `React.unmountComponentAtNode(node.$$class ? node[0] : node)`
  end

end

Element.instance_eval do
  class ::Element::DummyContext < React::Component::Base
  end
  def render(&block)
    React.render(React::RenderingContext.render(nil) {::Element::DummyContext.new.instance_eval &block}, self)
  end
end if Object.const_defined?("Element")
