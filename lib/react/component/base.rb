require 'react/component'

module React
  module Component
    class Base
      def self.inherited(child)
        child.send(:include, React::Component)
      end
    end
  end
end
