require 'opal'
require 'opal-jquery'
require "json"
require 'react'

class Window
  def self.set_interval(delay, &block)
    `window.setInterval(function(){#{block.call}}, #{delay.to_i})`
  end
end

class Comment
  include React::Component

  def render
    converter = Native(`new Showdown.converter()`)
    raw_markup = converter.makeHtml(params[:children].to_s)
    div class_name: "comment" do
      h2(class_name: "commentAuthor") { params[:author] }
      span(dangerously_set_inner_HTML: {__html: raw_markup}.to_n)
    end
  end
end

class CommentList
  include React::Component

  def render
    div class_name: "commentList" do
      params[:data].each_with_index.map do |comment, idx|
        present(Comment, author: comment["author"], key: idx) { comment["text"] }
      end
    end
  end
end

class CommentForm
  include React::Component

  def render
    f = form(class_name: "commentForm") do
      input type: "text", placeholder: "Your name", ref: "author"
      input type: "text", placeholder: "Say something...", ref: "text"
      input type: "submit", value: "Post"
    end

    f.on(:submit) do |event|
      event.prevent_default
      author = self.refs[:author].dom_node.value.strip
      text = self.refs[:text].dom_node.value.strip
      return if !text || !author
      self.emit(:comment_submit, {author: author, text: text})
      self.refs[:author].dom_node.value = ""
      self.refs[:text].dom_node.value = ""
    end
  end
end

class CommentBox
  include React::Component
  after_mount :load_comments_from_server, :start_polling
  define_state(:data) { [] }

  def load_comments_from_server
    HTTP.get(params[:url]) do |response|
      if response.ok?
        self.data = JSON.parse(response.body)
      else
        puts "failed with status #{response.status_code}"
      end
    end
  end

  def start_polling
    Window.set_interval(params[:poll_interval]) { load_comments_from_server }
  end

  def handle_comment_submit(comment)
    comments = self.data
    comments.push(comment)
    self.data = comments

    HTTP.post(params[:url], payload: comment) do |response|
      if response.ok?
        self.data = JSON.parse(response.body)
      else
        puts "failed with status #{response.status_code}"
      end
    end
  end

  def render
    div class_name: "commentBox" do
      h1 { "Comments" }
      present CommentList, data: self.data
      present(CommentForm).on(:comment_submit) {|c| handle_comment_submit(c) }
    end
  end
end


Document.ready? do
  React.render React.create_element(CommentBox, url: "comments.json", poll_interval: 2000), `document.getElementById('content')`
end
