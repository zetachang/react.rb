# This example shows how to save a node, instead of rendering it.

# Normally the DSL "emits" nodes into the rendering buffer as they are generated
# similar to a put statement.

# But what if you want to create some nodes and then use them later.

# The following example shows how to do this.  The key is the "as_node" method
# which "pulls" the rendered node back out of the rendering buffer and returns it.
# You may store it in some structure, or pass it as a parameter to another component.

# When it is time to render the component use the .render method, which pushes the
# node into the render buffer.

# The example is also good to understand the difference between generating a node, and
# rendering it.  You can see from the time stamps, that creating the node, does not
# render it.  That happens only when react generates the rendered virtual DOM.  Cool huh?

# This is slightly different and MORE typing than react, which is contrary to the goals
# of reactive-ruby, so some explanation is in order.

# In order to keep the DSL as short and sweet as possible, reactive-ruby assumes that
# normally when you generate a node, you will want it pushed into the render buffer
# (again just like a put statement.)

# So when you DONT want this behavior you do have to do some extra typing, i.e. you have
# explicitly use the .to_node and .render methods, to circumvent the rendering process.

# Note that under the hood there is nothing going on different than in straight react.

class NodeChildren

  include React::Component

  required_param :name

  def render
    tr { td {name}; td { '%.04f' %  Time.now.to_f } }
  end

end

class Nodes

  include React::Component

  def render
    start_time = Time.now
    nodes = (0..10).collect { |i| NodeChildren(name: "I am node #{i}!").as_node }
    div {
      table {
        tbody {
          tr { th {"Node"}; th {"rendered at"} }
          tr { td {"table (parent)"}; td {'%.04f' %  Time.now.to_f}}
          nodes.each &:render
        }
      }
    }
  end

end
