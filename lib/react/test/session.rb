module React
  module Test
    class Session
      def mount(component_klass, params = {})
        @element = React.create_element(component_klass, params)
        component
      end

      def instance
        @instance ||= Native(`React.addons.TestUtils.renderIntoDocument(#{element.to_n})`)
      end

      def element
        @element
      end

      def component
        @component ||= `#{instance.to_n}._getOpalInstance.apply(#{instance})`
      end

      def update_params(params)
        component.set_props(params)
      end
    end
  end
end

