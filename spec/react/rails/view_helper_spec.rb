require 'spec_helper'

RSpec.describe React::Rails::ViewHelper, type: :helper do
  it 'implements react_component' do
    expect(helper).to respond_to(:react_component)
  end

  it 'aliases react-rails react_component' do
    expect(helper).to respond_to(:pre_opal_react_component)
  end
end
