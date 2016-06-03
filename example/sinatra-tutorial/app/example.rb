require 'opal'
require 'browser/interval'      # gives us wrappers on javascript methods such as setTimer and setInterval
require 'jquery'
require 'opal-jquery'  # gives us a nice wrapper on jQuery which we will use mainly for HTTP calls
require "json"         # json conversions
require 'reactrb'   # and the whole reason we are gathered here today!
  
Document.ready? do  # Document.ready? is a opal-jquery method.  The block will run when doc is loaded
  
  # render an instance of the CommentBox component at the '#content' element.  
  # url and poll_interval are the initial params for this comment box
  React.render(                                            
    React.create_element(
      CommentBox, url: "comments.json", poll_interval: 2), 
    Element['#content']
    )
end

class CommentBox
  
  # A react component is simply a class that has a "render" method.
  
  # But including React::Component mixin provides a nice dsl, and many other features
  
  include React::Component
  
  # Components can have parameters that are passed in when the component is first "mounted"
  # and then updated as the application state changes.  In this case url, and poll_interval will
  # never change since this is the top level component.
  
  required_param :url
  required_param :poll_interval
  
  # Components also may have internal state variables, which are like instance variables,
  # with one added feature:  Changing state causes a rerender to occur.
  
  # The "comments" state is being initialized by parsing the javascript object at window.initial_comments
  # This is not a react feature, but was just set up in the HTML header (see config.ru for how this was done).
  
  define_state comments: JSON.from_object(`window.initial_comments`)
  
  # The following call backs are made during the component lifecycle:
  
  # before_mount          before component is first rendered
  # after_mount           after component is first rendered, after DOM is loaded.  ONLY CALLED ON CLIENT
  # before_receive_props  when component is being about to be rerendered by an outside state change.  CANCELLABLE
  # before_update         just before a rerender, and not cancellable.
  # after_update          after DOM has been updated.
  # before_unmount        before component instance will be removed.  Use this to kill low level handlers etc.
  
  # just to show off how these callbacks work we have separated setting up a repeating fetch into three pieces.
  
  # before mounting we will initialize a polling loop, but we don't want to start it yet.  
  
  before_mount do
    @fetcher = every(poll_interval) do          # we use the opal browser utility to call the server every poll_interval seconds  
      HTTP.get(url) do |response|               # notice that params poll_interval, and url are accessed as instance methods
        if response.ok?               
          comments! JSON.parse(response.body)   # comments!(value) updates the state and notifies react of the state change
        else
          puts "failed with status #{response.status_code}"
        end
      end
    end
  end
  
  # once we have things up and displayed lets start polling for updates
    
  after_mount do
    puts "start me up!"
    @fetcher.start
  end
  
  # finally our component should be a good citizen and stop the polling when its unmounted
  
  before_unmount do
    @fetcher.stop
  end
  
  # components can have their own methods like any other class
  # in this case we receive a new comment and send it the server
  
  def send_comment_to_server(comment)
    HTTP.post(url, payload: comment) do |response|
      puts "failed with status #{response.status_code}" unless response.ok?
    end
    comment
  end
  
  # every component must implement a render method.  The method must generate a single
  # react virtual DOM element.  React compares the output of each render and determines
  # the minimum actual DOM update needed.
  
  # A very common mistake is to try generate two or more elements (or none at all.) Either case will
  # throw an error.  Just remember that there is already a DOM node waiting for the output of the render
  # hence the need for exactly one element per render.
  
  def render
    
    # the dsl syntax is simply a method call, with params hash, followed by a block
    # the built in dsl methods correspond to the standard HTML5 tags such as div, h1, table, tr, td, span etc.
    #return div.comment { h1 {"hello"} }
    div class: "commentBox" do          # just like <div class="commentBox">
      
      h1 { "Comments" }                 # yep just like <h1>Comments</h1>
      
      # Custom components use their class name, as the tag.  Notice that the comments state is passed to  
      # to the CommentList component.  This is the normal React paradigm: Data flows towards the leaf nodes.
                                      
      CommentList comments: comments   
      
      # Sometimes its necessary for data to move upwards, and react provides several ways to do this.
      
      # In this case we need to know when a new comment is submitted. So we pass a callback proc.
      
      # The callback takes the new comment and sends it to the server and then pushes it onto the comments list.  
      # Again the comments! method is used to signal that the state is changing.  The use of the "bang" pseudo 
      # operator is important as the value of comments has NOT changed (its still tha same array), but its 
      # internal state has.
      
      CommentForm submit_comment: lambda { |comment| comments! << send_comment_to_server(comment)}
      
    end
  end
  
end

# Our second component!

class CommentList
  
  include React::Component
  
  # As we saw above a CommentList component takes a comments parameter
  # Here we introduce optional parameter type checking.  The syntax [Hash] means "Array of Hashes"
  # In our case each comment is a hash with an author and text key.
  
  # Failure to match the type puts a warning on the console not an error, 
  # and only in development mode not production.
  
  required_param :comments, type: Array 
  
  # This is a good place to think more about the component lifecycle.  The first time 
  # CommentList is mounted, comments will be the initial array of author, text hashes.
  # As new comments are added the component will receive new params.  However the component
  # does NOT reinitialize its state.  If changes in state are needed as result of incoming param changes
  # the before_receive_props call back can be used.

  def render
    
    # Lets render some comments - all we need to do is iterate over the comments array using the usual 
    # ruby "each" method.  
    
    # This is a good place to clarify how the DSL works.  Notice that we use comments.each NOT comments.collect
    # When a tag method (such as div, or Comment) is called its "output" is internally pushed into a render buffer.
    # This simplifies the DSL by separating the control flow from the output, but can sometimes be a bit confusing.
     
    div.commentList.and_another_class.and_another do   # you can also include the class haml style (tx to @dancinglightning!)
      comments.each do |comment|
        # By now we are getting used to the react paradigm:  Stuff comes in, is processed, and then
        # passed to next lower level.  In this case we pass along each author-text pair to the Comment component.
        Comment author: comment[:author], text: comment[:text], hash: comment
      end
    end
  end
  
end

# Notice that the above CommentList component had no state.  Each time its parameters change, it simply re-renders.
# CommentForm does have internal state as we will see...

class CommentForm
  
  include React::Component
  
  # While declaring the type of a param is optional its handy not only for debug, but also to let React create
  # appropriate helpers based on the type.  In this case we are passing in a Proc, and so React will treat the
  # "submit_comment" param specially.  Instead of submit_comment returning its value (as the previous params have done)
  # it will call the associated Proc, thus allow CommentForm to communicate state changes back to the parent.
  
  required_param :submit_comment, type: Proc
  
  # We are going to have 2 state variable.  One for each field in the comment.  As the user types,
  # these state variables will be updating causing a rerender of the CommentForm (but no other components.)
  
  define_state :author, :text

  def render
    div do
      div do
        
        "Author: ".span  # Note the shorthand for span { "Author" }. You can do this with br, span, th, td, and para (for p) tags
        
        # Now we are going to generate an input tag.  Notice how the author state variable is provided. Referencing
        # author is what will cause us to re-render and update the input as the value of author changes.
        # React will optimize the updates so parts that are not changing will not be effected.
        
        input.author_name(type: :text, value: author, placeholder: "Your name", style: {width: "30%"}).
          # and we attach an on_change handler to the input.  As the input changes we simply update author.
          on(:change) { |e| author! e.target.value } 
          
      end
      
      div do
        # lets have some fun with the text.  Same deal as the author except we will use a text area...
        div(style: {float: :left, width: "50%"}) do
          textarea(value: text, placeholder: "Say something...", style: {width: "90%"}, rows: 30).
            on(:change) { |e| text! e.target.value }
        end
        # and lets use Showdown to allow for markdown, and display the mark down to the left of input
        # we will define Showdown later, and it will be our first reusable component, as we will use it twice.
        div(style: {float: :left, width: "50%"}) do
          Showdown markup: text
        end
      end
      
      # Finally lets give the use a button to submit changes.  Why not? We have come this far!
      # Notice how the submit_comment proc param allows us to be ignorant of how the update is made.
      
      # Notice that (author! "") updates author, but returns the current value.  
      # This is usually the desired behavior in React as we are typically interested in state changes,
      # and before/after values, not simply doing a chained update of multiple variables.
      
      button { "Post" }.on(:click) { submit_comment :author => (author! ""), :text => (text! "") }
      
    end
  end
end

# Wow only two more components left!  This one is a breeze.  We just take the author, and text and display
# them.  We already know how to use our Showdown component to display the markdown so we can just reuse that.

class Comment
  
  include React::Component
  
  required_param :author
  required_param :text
  required_param :hash, type: Hash

  def render
    div.comment do
      h2.comment_author { author } # NOTE: single underscores in haml style class names are converted to dashes
                                   # so comment_author becomes comment-author, but comment__author would be comment_author
                                   # this is handy for boot strap names like col-md-push-9 which can be written as col_md_push_9
      Showdown markup: text
    end
  end
  
end

# Last but not least here is our ShowDown Component

class Showdown
  
  include React::Component
  
  required_param :markup
  
  def render
    
    # we will use some Opal lowlevel stuff to interface to the javascript Showdown class
    # we only need to build the converter once, and then reuse it so we will use a plain old
    # instance variable to keep track of it.
    
    @converter ||= Native(`new Showdown.converter()`)  
    
    # then we will take our markup param, and convert it to html
    
    raw_markup = @converter.makeHtml(markup) if markup
    
    # React.js takes a very dim view of passing raw html so its purposefully made
    # difficult so you won't do it by accident.  After all think of how dangerous what we 
    # are doing right here is!  
    
    # The span tag can be replaced by any tag that could sensibly take a child html element.  
    # You could also use div, td, etc.
    
    span(dangerously_set_inner_HTML: {__html: raw_markup})
    
  end
  
end







