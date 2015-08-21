# controllers/home_controller.rb
class HomeController < ApplicationController
  def show
    render_component  # by default render_component will use the controller name to find the appropriate component
  end
end