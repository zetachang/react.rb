require "spec_helper"

describe React::Event do
  it "should bridge attributes of native SyntheticEvent (see http://facebook.github.io/react/docs/events.html#syntheticevent)" do
    element = React.create_element('div').on(:click) do |event|
      expect(event.bubbles).to eq(`#{event.to_n}.bubbles`)
      expect(event.cancelable).to eq(`#{event.to_n}.cancelable`)
      expect(event.current_target).to eq(`#{event.to_n}.currentTarget`)
      expect(event.default_prevented).to eq(`#{event.to_n}.defaultPrevented`)
      expect(event.event_phase).to eq(`#{event.to_n}.eventPhase`)
      expect(event.is_trusted?).to eq(`#{event.to_n}.isTrusted`)
      expect(event.native_event).to eq(`#{event.to_n}.nativeEvent`)
      expect(event.target).to eq(`#{event.to_n}.target`)
      expect(event.timestamp).to eq(`#{event.to_n}.timeStamp`)
      expect(event.event_type).to eq(`#{event.to_n}.type`)
      expect(event).to respond_to(:prevent_default)
      expect(event).to respond_to(:stop_propagation)
    end
    instance = renderElementToDocument(element)
    simulateEvent(:click, instance)
  end
end