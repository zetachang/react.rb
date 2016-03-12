require 'react/test/dsl'
require 'react/test/matchers/render_html_matcher'

RSpec.configure do |config|
  config.include React::Test::DSL, type: :component
  config.include React::Test::Matchers, type: :component

  config.after do
    React::Test.reset_session!
  end

  config.before do
    # nothing yet
  end
end
