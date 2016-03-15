module React
  module Test
    class Session
      DSL_METHODS = %i[mount instance native element update_params
        force_update! html].freeze

      def mount(component_klass, params = {})
        @element = React.create_element(component_klass, params)
        instance
      end

      def instance
        @instance ||= `#{native.to_n}._getOpalInstance.apply(#{native})`
      end

      def native
        @native ||= Native(
          `React.addons.TestUtils.renderIntoDocument(#{element.to_n})`)
      end

      def element
        @element
      end

      def update_params(params)
        native.set_props(params)
      end

      def force_update!
        native.force_update!
      end

      def html
        # How can we get the current ReactElement w/o violating private APIs?
        elem = Native(native[:_reactInternalInstance][:_currentElement])
        React.render_to_static_markup(elem)
      end
    end
  end
end

