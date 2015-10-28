class ReactAPIDemo

  include React::Component

  before_mount do
    @click_count = 0 # normally we would just use a state variable, but we want to demo using force_update!
  end

  after_mount do
    # to demonstrate the use of dom_node we will attach a click handler AFTER rendering is complete
    Element[dom_node].on(:click) do
      alert("I got attached using some low level stuff... now watch and you will see I will force a rerender") if @click_count == 0
      @click_count += 1
      force_update!
    end
  end

  def render
    #  Normally you would just attach the handler directly to the node like this:
    # "Click Me Please".on(:click) { alert 'I was attached during rendering' }
    if mounted?
      "I was already mounted, and you have clicked me #{@click_count} time#{'s' if @click_count > 1}, but you can click me again!" #.on(:click) { alert("I was attached the normal way")}
    else
      "This is the first render.  click me to rerender!"
    end

  end

end
