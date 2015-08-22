# app/views/components/home.rb

module Components 
  module Home
    class Show

      include React::Component   # will create a new component named Home

      export_component           # export the component name into the javascript space 

      def render  
        puts "Rendering my first component!"
        "hello"                  # render "hello" 
      end

    end
  end
end