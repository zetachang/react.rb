class ColorList
  
  # An important part of building a reusable component is being able to pass in other components.
  # 
  # Any component that has a block will receive all of the elements (nodes) generated in that block as children.
  # These are accessed through the special "children" param which returns a enumerator.
  #
  # In some cases it is clearer to pass the child as a parameter.  In this case the child is accessed in
  # the normal way by using the named parameter method.
  #
  # The ColorList component demonstrates both ways to pass children to a component.  ColorList takes three
  # parameters - a list of color styles that will be used in sequence when rendering the list, and an optional
  # header and footer that will be rendered before and after the list.
  # 
  # Each of the children provided in the block will be displayed in order with a different color taken from the color list.
  
  include React::Component
  
  required_param :colors, type: [String]          # note the use of typing which is not required, but useful for debugging 
  optional_param :header, type: React::Element    # [String] means and array of strings
  optional_param :footer, type: React::Element
    
  def render
    div do 
      # sending the render method will place the element into the render buffer
      header.render if header
      ul do
        # children is an enumerable, so any method such as each, each_with_index, etc will work
        children.each_with_index do |child, i|  
          ul do
            # render will take a param list, and if present will cause the child to be cloned, and the 
            # additional params will be shallow merged with any existing params
            child.render(style: {color: colors[i % colors.length]})
          end
        end
      end
      footer.render if footer
    end
  end
  
end

class Reuse 
  
  include React::Component
  
  def render
    ColorList(colors: [:red, :blue, :green], header: h1 {"I am the child header passed as a param"}) do
      # we are going to pass 5 child elements to our ColorList as well as the header
      "I am the first item".span   # note the alternative to span { "..." }
      "I am the second item".span
      ColorList(colors: [:pink, :yellow]) {"I am a nested guy".span; "and so am i".span}
      "I am the fourth item".span
      div {"I am a div item".br; "with 2 lines"}
    end
  end 
  
end
        