require 'opal'
require 'jquery'
require 'opal-jquery'
require 'opal-haml'
require 'vienna'
require "react"

require 'models/todo'

require "components/app.react"

Document.ready? do
  element = React.create_element(TodoAppView, filter: "all")
  component = React.render(element, Element.find('#todoapp').get(0))

  Vienna::Router.new.tap do |router|
    router.route('/:filter') do |params|
      component.set_props(filter: params[:filter].empty? ? "all" : params[:filter])
    end
  end.update

end
