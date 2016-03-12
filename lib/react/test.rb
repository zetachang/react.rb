require 'react/test/session'
require 'react/test/dsl'

module React
  module Test
    class << self
      def current_session
        @current_session ||= Session.new
      end

      def reset_session!
        @current_session = nil
      end
    end
  end
end
