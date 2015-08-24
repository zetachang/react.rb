# controllers/home_controller.rb
class HomeController < ApplicationController
  def show
    render_component  "::Showz", say_hello_to: params[:say_hello_to] # by default render_component will use the controller name to find the appropriate component
  end
end