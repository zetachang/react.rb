module React
  module Component
    class Base
      def self.inherited(child)
        child.include(Component)
      end
    end
  end
end
