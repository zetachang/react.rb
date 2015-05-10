module React
  module Testing
    `var ReactTestUtils = React.addons.TestUtils`
    
    def simulate_event(event_name, dom_element, event_data = {})
      simulator = Native(`ReactTestUtils.Simulate`)
      simulator[event_name].call(dom_element, event_data)
    end
    
    def render_to_document(element)
      `ReactTestUtils.renderIntoDocument(element)`
    end
  end
end
