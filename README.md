# React.rb

[![Gem Version](https://badge.fury.io/rb/react.rb.svg)](http://badge.fury.io/rb/react.rb)
[![Code Climate](https://codeclimate.com/github/zetachang/react.rb/badges/gpa.svg)](https://codeclimate.com/github/zetachang/react.rb)

**React.rb is an [Opal Ruby](http://opalrb.org) wrapper of [React.js library](http://facebook.github.io/react/)**.

It lets you write reactive UI components, with Ruby's elegance and compiled to run in JavaScript. :heart:

This fork of the original react.rb gem is a work in progress.  Currently it is being used in a large rails app, so until a better guide can be written we will just assume you will use it a rails app too.  However it does work fine by itself.  Good luck.

## Installation

Currently this branch (reactive-ruby) is being used with the following configuration.  
It is suggested to begin with this
set of gems which is known to work and then add / remove them as needed.  Let us know if you discover anything.

Currently this has been tested to some extent with rails 4x

```ruby
gem 'react-rails', git: "https://github.com/catprintlabs/react-rails.git", :branch => 'isomorphic-methods-support'  # you need this branch of react-rails
gem 'opal', git: "https://github.com/catprintlabs/opal.git"
gem 'opal-jquery'
gem 'opal-rails'                      # not sure if you need this in all cases
gem 'opal-browser'                    # gets you things like intervals (every method)
gem 'reactive-ruby'
gem 'reactive_record'                 # if you want to interface to active_record
gem 'react-bootstrap-rails'           # if you want to use boot strap styles
gem 'react-router-rails', '~>0.13.3'  # if you want a single page app router
gem 'reactor-router'                  # same as above
```

Your react components go into `assets/javascript/components/` 

You need a file `assets/javascripts/components/components.rb` like this:

```
require 'opal'
require 'react'
require 'reactive-ruby'
require 'reactive-record'
require 'react_router'
require 'reactive-router'
require_tree './components'
```

The `react-rails` gem will load this code into the server side prerendering environment.

Your `assets/javascript/application.rb` file looks like this:

```
require 'jquery-1.11.3'     # you probably want this
require 'bootstrap'         # if you are using bootstrap
require 'components'         
require 'react_bootstrap'
require 'react_ujs' 
```

Note that any files needed for server side rendering go into components, everything else goes
into application.rb.

Okay that is your setup.

Now for a simple component:

```ruby
# assets/javascript/components/home.rb
class Home

  include React::Component                    # will create a new component named Home
  
  def render                                    
    "hello"                                   # render "hello" 
  end
end
```

Components work just like views so in your home controller
```ruby
# controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    render_component  # by default render_component will use the controller name to find the appropriate component
  end
end
```


and in your Opal application,

```ruby
require "opal-react"
require "react"

React.render(React.create_element('h1'){ "Hello World!" }, `document.body`)
```

For a complete example covering most key features, as well as integration with a server (Sinatra, etc), see setup of [Examples](example/tutorial).  For additional information on integrating Opal with a server see the [official docs](http://opalrb.org/docs/) of Opal.

## React Overview

### Basics

The biggest problem with react is that its almost too simple.

In react you define components.  Components are simply classes that have a "render" method.   The render method "draws" a chunk of
HTML.  

Here is a very simple component:

```ruby

require 'opal'
require 'opal-react'

class Hello
  def render
    "hello world"
  end
end

# to use the component we first create an instance o

Include the `React::Component` mixin in a class to turn it into a react component

```ruby
require 'opal'
require 'opal-react'

class HelloMessage

  include React::Component                    # will create a new component named HelloMessage
  
  MSG = {great: 'Cool!', bad: 'Cheer up!'}

  optional_param :mood
  required_param :name
  define_state   :foo, "Default greeting"

  before_mount do                             # you can define life cycle callbacks inline
    foo! "#{name}: #{MSG[mood]}" if mood      # change the state of foo using foo!, read the state using foo
  end

  after_mount :log                            # you can also define life cycle callbacks by reference to a method

  def log
    puts "mounted!"
  end
  
  def render                                  # render method MUST return just one component  
    div do                                    # basic dsl syntax component_name(options) { ...children... }                                    
      span { "#{foo} #{name}!" }              # all html5 components are defined with lower case text
    end
  end
end

class App
  include React::Component

  def render
    HelloMessage name: 'John', mood: :great   # new components are accessed via the class name
  end
end

# later we will talk about nicer ways to do this:  For now wait till doc is loaded
# then tell React to create an "App" and render it into the document body.

`window.onload = #{lambda {React.render(React.create_element(App), `document.body`)}}`

# -> console says: mounted!
```

* Callback of life cycle could be created through helpers `before_mount`, `after_mount`, etc
* `this.props` is accessed through method `self.params`
* Use helper method `define_state` to create setter & getter of `this.state` for you
* For the detailed mapping to the original API, see [this issue](https://github.com/zetachang/react.rb/issues/2) for reference. Complete reference will come soon.

### Element Building DSL

As a replacement of JSX, include `React::Component` and you can build `React.Element` hierarchy without all the `React.create_element` noises.

```ruby
def render
  div do
    h1 { "Title" }
    h2 { "subtitle"}
    div(class_name: 'fancy', id: 'foo') { span { "some text #{interpolation}"} }
    present FancyElement, fancy_props: '10'
  end
end
```

### Props validation

How about props validation? Inspired by [Grape API](https://github.com/intridea/grape), props validation rule could be created easily through `params` class method as below,

```ruby
class App
  include React::Component

  params do
    requires :username, type: String
    requires :enum, values: ['foo', 'bar', 'awesome']
    requires :payload, type: Todo # yeah, a plain Ruby class
    optional :filters, type: Array[String]
    optional :flash_message, type: String, default: 'Welcome!' # no need to feed through `getDefaultProps`
  end

  def render
    div
  end
end
```

### Mixins

Simply create a Ruby module to encapsulate the behavior. Example below is modified from the original [React.js Exmaple on Mixin](http://facebook.github.io/react/docs/reusable-components.html#mixins). [Opal Browser](https://github.com/opal/opal-browser) syntax are used here to make it cleaner.

```ruby
module SetInterval
  def self.included(base)
    base.class_eval do
      before_mount { @interval = [] }
      before_unmount do
        # abort associated timer of a component right before unmount
        @interval.each { |i| i.abort }
      end
    end
  end

  def set_interval(seconds, &block)
    @interval << $window.every(seconds, &block)
  end
end

class TickTock
  include React::Component
  include SetInterval

  define_state(:seconds) { 0 }

  before_mount do
    set_interval(1) { self.seconds = self.seconds + 1 }
    set_interval(1) { puts "Tick!" }
  end

  def render
    span do
      "React has been running for: #{self.seconds}"
    end
  end
end

React.render(React.create_element(TickTock), $document.body.to_n)

$window.after(5) do
  React.unmount_component_at_node($document.body.to_n)
end

# => Tick!
# => ... for 5 times then stop ticking after 5 seconds
```


### A Simple Component

A ruby class which define method `render` is a valid component.

```ruby
class HelloMessage
  def render
    React.create_element("div") { "Hello World!" }
  end
end

puts React.render_to_static_markup(React.create_element(HelloMessage))

# => '<div>Hello World!</div>'
```

### More complicated one

To hook into native ReactComponent life cycle, the native `this` will be passed to the class's initializer. And all corresponding life cycle methods (`componentDidMount`, etc) will be invoked on the instance using the snake-case method name.

```ruby
class HelloMessage
  def initialize(native)
    @native = Native(native)
  end

  def component_will_mount
    puts "will mount!"
  end

  def render
    React.create_element("div") { "Hello #{@native[:props][:name]}!" }
  end
end

puts React.render_to_static_markup(React.create_element(HelloMessage, name: 'John'))

# => will_mount!
# => '<div>Hello John!</div>'
```
## Example

* React Tutorial: see [example/react-tutorial](example/react-tutorial), the original CommentBox example.
* TodoMVC: see [example/todos](example/todos), your beloved TodoMVC <3.

## TODOS

* Documentation
* API wrapping coverage of the original js library (pretty close though)
* React Native?

## Developing

To run the test case of the project yourself.

1. `git clone` the project
2. `bundle install`
3. `bundle exec rackup`
4. Open `http://localhost:9292` to run the spec

## Contributions

This project is still in early stage, so discussion, bug report and PR are really welcome :wink:.

## Contact

[David Chang](http://github.com/zetachang)
[@zetachang](https://twitter.com/zetachang)

## License

In short, React.rb is available under the MIT license. See the LICENSE file for more info.
