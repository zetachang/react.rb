require 'opal'
require 'browser/interval'      # gives us wrappers on javascript methods such as setTimer and setInterval
require 'jquery'
require 'opal-jquery'  # gives us a nice wrapper on jQuery which we will use mainly for HTTP calls
require "json"         # json conversions
require 'reactrb'   # and the whole reason we are gathered here today!
require 'react-router'
require 'reactive-router'
require 'basics'
require 'reuse'
require 'items'
require 'rerendering'
require 'nodes'
require 'react_api_demo'


class Show

  include React::Router

  backtrace :on

  routes(path: "/") do
    route(path: "basics", name: "basics", handler: Basics)
    route(path: "reuse", name: "reuse", handler: Reuse)
    route(path: "rerendering", name: "rerendering", handler: Rerendering)
    route(path: "nodes", name: "nodes", handler: Nodes)
    route(path: "api_demo", name: "api_demo", handler: ReactAPIDemo)
    redirect(from: "/", to: "basics")
  end

  def show
    puts "mounted the show method"
    div do
      div do
        link(to: "basics") { "Basics" }; br
        link(to: "reuse") { "Reusable Components" }; br
        link(to: "rerendering") { "Rerendering Test" }; br
        link(to: "nodes") { "Saving and using rendered nodes" }; br
        link(to: "api_demo") { "Low Level React API" }; br
      end
    route_handler
    end
  end

end

Document.ready? do

  React.render(React.create_element(Show), Element['#content'])

end
