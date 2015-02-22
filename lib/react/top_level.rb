require "native"
require 'active_support'

module React
  HTML_TAGS = %w(a abbr address area article aside audio b base bdi bdo big blockquote body br
                button canvas caption cite code col colgroup data datalist dd del details dfn
                dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
                h6 head header hr html i iframe img input ins kbd keygen label legend li link
                main map mark menu menuitem meta meter nav noscript object ol optgroup option
                output p param picture pre progress q rp rt ruby s samp script section select
                small source span strong style sub summary sup table tbody td textarea tfoot th
                thead time title tr track u ul var video wbr)
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
                tabIndex target title type useMap value width wmode dangerously_set_inner_HTML)

  def self.create_element(type, properties = {}, &block)
    React::API.create_element(type, properties, &block)
  end

  def self.render(element, container)
    component = Native(`React.render(#{element.to_n}, container, function(){#{yield if block_given?}})`)
    component.class.include(React::Component::API)
    component
  end

  def self.is_valid_element(element)
    element.kind_of?(React::Element) && `React.isValidElement(#{element.to_n})`
  end

  def self.render_to_string(element)
    `React.renderToString(#{element.to_n})`
  end

  def self.render_to_static_markup(element)
    `React.renderToStaticMarkup(#{element.to_n})`
  end

  def self.unmount_component_at_node(node)
    `React.unmountComponentAtNode(node)`
  end
end
