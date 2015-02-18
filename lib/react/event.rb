module React
  class Event
    include Native
    alias_native :bubbles, :bubbles
    alias_native :cancelable, :cancelable
    alias_native :current_target, :currentTarget
    alias_native :default_prevented, :defaultPrevented
    alias_native :event_phase, :eventPhase
    alias_native :is_trusted?, :isTrusted
    alias_native :native_event, :nativeEvent
    alias_native :target, :target
    alias_native :timestamp, :timeStamp
    alias_native :event_type, :type
    alias_native :prevent_default, :preventDefault
    alias_native :stop_propagation, :stopPropagation
    # Clipboard
    alias_native :clipboard_data, :clipboardData
    # Keyboard
    alias_native :alt_key, :altKey
    alias_native :char_code, :charCode
    alias_native :ctrl_key, :ctrlKey
    alias_native :get_modifier_state, :getModifierState
    alias_native :key, :key
    alias_native :key_code, :keyCode
    alias_native :locale, :locale
    alias_native :location, :location
    alias_native :meta_key, :metaKey
    alias_native :repeat, :repeat
    alias_native :shift_key, :shiftKey
    alias_native :which, :which
    # Focus
    alias_native :related_target, :relatedTarget
    # Mouse
    alias_native :alt_key, :altKey
    alias_native :button, :button
    alias_native :buttons, :buttons
    alias_native :client_x, :clientX
    alias_native :client_y, :clientY
    alias_native :ctrl_key, :ctrlKey
    alias_native :get_modifier_state, :getModifierState
    alias_native :meta_key, :metaKey
    alias_native :page_x, :pageX
    alias_native :page_y, :pageY
    alias_native :related_target, :relatedTarget
    alias_native :screen_x, :screen_x
    alias_native :screen_y, :screen_y
    alias_native :shift_key, :shift_key
    # Touch
    alias_native :alt_key, :altKey
    alias_native :changed_touches, :changedTouches
    alias_native :ctrl_key, :ctrlKey
    alias_native :get_modifier_state, :getModifierState
    alias_native :meta_key, :metaKey
    alias_native :shift_key, :shiftKey
    alias_native :target_touches, :targetTouches
    alias_native :touches, :touches
    # UI
    alias_native :detail, :detail
    alias_native :view, :view
    # Wheel
    alias_native :delta_mode, :deltaMode
    alias_native :delta_x, :deltaX
    alias_native :delta_y, :deltaY
    alias_native :delta_z, :deltaZ

    BUILT_IN_EVENTS = %w{onCopy onCut onPaste onKeyDown onKeyPress onKeyUp
      onFocus onBlur onChange onInput onSubmit onClick onDoubleClick onDrag
      onDragEnd onDragEnter onDragExit onDragLeave onDragOver onDragStart onDrop
      onMouseDown onMouseEnter onMouseLeave onMouseMove onMouseOut onMouseOver
      onMouseUp onTouchCancel onTouchEnd onTouchMove onTouchStart onScroll}

    def initialize(native_element)
      @native = native_element
    end
  end
end
