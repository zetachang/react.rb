require 'react/jsx'
require 'tilt'
require "sprockets"

module Opal
  module React
    module JSX
      class Template < Tilt::Template
        self.default_mime_type = 'application/javascript'

        def prepare
        end

        def evaluate(scope, locals, &block)
          @output ||= ::React::JSX.compile(data)
        end
      end
    end
  end
end

Sprockets.register_engine '.jsx', Opal::React::JSX::Template
