require 'opal'
require 'browser/interval'      # gives us wrappers on javascript methods such as setTimer and setInterval
require 'jquery'
require 'opal-jquery'  # gives us a nice wrapper on jQuery which we will use mainly for HTTP calls
require "json"         # json conversions
require 'reactive-ruby'   # and the whole reason we are gathered here today!
require 'react-router'
require 'reactive-router'
require 'basics'
require 'reuse'
require 'items'


class Show

  include React::Router

  backtrace :on

  routes(path: "/") do
    route(path: "basics", name: "basics", handler: Basics)
    route(path: "reuse", name: "reuse", handler: Reuse)
    redirect(from: "/", to: "basics")
  end

  def show
    puts "mounted the show method"
    div do
      div do
        link(to: "basics") { "Basics" }; br
        link(to: "reuse") { "Reusable Components" }; br
      end
    route_handler
    end
  end

end

Document.ready? do

  React.render(React.create_element(Show), Element['#content'])
  
end


