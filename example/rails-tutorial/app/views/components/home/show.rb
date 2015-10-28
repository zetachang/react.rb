# app/views/components/home/show.rb

module Components

  module Home

    class Show

      include React::Component   # will create a new component named Show

      optional_param :say_hello_to
      backtrace :on
      def render
        puts "Rendering my first component!"
        List(first_element: div { "bhwahaha" }) do
          "hello #{'there '+say_hello_to if say_hello_to}".span # render "hello" with optional 'there ...'
          "goodby".span
        end
      end

    end

    class List

      include React::Component

      required_param :first_element #, type: React::Element

      backtrace :on

      def render
        ul do
          li do
            first_element.render
          end
          children.each do |child|
            li do
              child.render(style: {color: :green})
              child.render(style: {color: :red})
            end
          end
        end
      end
    end
  end

end
