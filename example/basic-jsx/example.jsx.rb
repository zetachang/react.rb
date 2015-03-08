require "opal"
require "react"
require "browser"

class Clock
  include React::Component

  def render
    message = "React has been successfully running for #{params[:elapsed].round} seconds."

    jsx %x{
      <p>{#{message}}</p>
    }
  end
end

class ExampleApp
  include React::Component

  def render
    jsx(%x{
      <Clock elapsed={#{params[:elapsed]}} />
    })
  end
end

React.expose_native_class(Clock, ExampleApp)

start = Time.now

$window.every(0.05) do
  element = React::Element.new(`<ExampleApp elapsed={#{Time.now - start}}/>`)
  container = `document.getElementById('container')`
  React.render element, container
end
