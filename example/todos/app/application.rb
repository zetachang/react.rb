require 'opal'
require 'jquery'
require 'opal-jquery'
require 'opal-haml'
require 'vienna'
require "react"

require 'models/todo'

require "components/app.react"

Document.ready? do
  # Render the top-level React.rb component, it will take care the rest
  React.render React.create_element(TodoAppView), Element.find('#todoapp').get(0)
end
