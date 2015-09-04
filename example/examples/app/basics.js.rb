class HelloMessage

  include React::Component                    # will create a new component named HelloMessage
  
  MSG = {great: 'Cool!', bad: 'Cheer up!'}

  optional_param :mood
  required_param :name
  define_state   :foo, "Default greeting"

  before_mount do
    foo! "#{name}: #{MSG[mood]}" if mood      # change the state of foo using foo!, read the state using foo
  end

  after_mount :log                            # notice the two forms of callback

  def log
    puts "mounted!"
  end
  
  def render                                  # render method MUST return just one component  
    div do                                    # basic dsl syntax component_name(options) { ...children... }                                    
      span { "#{foo} #{name}!" }              # all html5 components are defined with lower case text
    end
  end
  
end

class Basics
  
  include React::Component

  def render
    HelloMessage name: 'John', mood: :great   # new components are accessed via the class name
  end
  
end

# later we will talk about nicer ways to do this:  For now wait till doc is loaded
# then tell React to create an "App" and render it into the document body.

# `window.onload = #{lambda {React.render(React.create_element(App), `document.body`)}}`