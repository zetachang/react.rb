require 'opal'
require 'jquery'
require 'opal-jquery'
require 'vienna'
require "react"

require 'models/todo'

require "components/app.react"

Document.ready? do
  element = React.create_element(TodoAppView, filter: "all")
  component = React.render(element, `document.getElementById('todoapp')`)

  Vienna::Router.new.tap do |router|
    router.route('/:filter') do |params|
      element = React.create_element(TodoAppView, filter: params[:filter].empty? ? "all" : params[:filter])
      component = React.render(element, `document.getElementById('todoapp')`)      
    end
  end.update

end
