require 'react/test'

module React
  module Test
    module DSL
      def component
        React::Test.current_session
      end

      Session::DSL_METHODS.each do |method|
        define_method method do |*args, &block|
          component.public_send(method, *args, &block)
        end
      end
    end
  end
end
