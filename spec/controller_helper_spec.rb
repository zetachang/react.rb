require 'spec_helper'

class TestController < ActionController::Base; end

RSpec.describe TestController, type: :controller do
  it { is_expected.to respond_to(:render_component) }
end
