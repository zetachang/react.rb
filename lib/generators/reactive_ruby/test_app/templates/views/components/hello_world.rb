module Components
  class HelloWorld
    include React::Component

    def render
      div do
        "Hello, World!".span
      end
    end
  end
end
