require "react"

class Comment < React::Component
  render do
    div do
      h2 { options[:auther] }
      span { options[:content] }
    end
  end
end

class CommentBox < React::Component
  # This will hook to `setState({data: })`
  define_state :data
  
  # Map to `componentDidMount`, which should also accept Proc
  after_mount :load_comments
  
  define_entity do
    Comment.order("id ASC").limit(params[:count])
  end
  
  def initialize
    self.data = []
  end
  
  def load_comments
    self.data = [{author: "David", content: "How's everyone?"}]
  end
  
  def submit_comment(comment)
    comments = self.data
    comments << comment
    # to trigger refresh
    self.data = comments
    #TODO Network request
  end
  
  render do
    div do |node|
      h1 { "Comments" }
      CommentList.render data: self.data
      CommentForm.render on_comment_submit: :submit_comment
    end
  end
end

class CommentList < React::Component  
  def render
    div do |node|
      options[:data].each_with_index do |comment, index|
        Comment.render author: comment.author, key: index do
          comment.text
        end
      end
    end
  end
end

class CommentForm < React::Component
  render do
    # Below is a form helper, 
    # which will wrap below to object {author: "David", text: "Awesome!"}
    # and emit event `comment_submit` on the component with the object
    form :submit => :comment_submit do |f|
      f.input  :auther, type: :text, placeholder: "Your name"
      f.input  :text,   type: :text, placeholder: "Type something..."
      f.submit "Post"
    end
  end
end

# By default, we render to `document.body`
React.render :comment_box, url: "comments.json", poll_interval: 2000