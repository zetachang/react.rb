# React.rb

[![Gem Version](https://badge.fury.io/rb/react.rb.svg)](http://badge.fury.io/rb/react.rb)
[![Code Climate](https://codeclimate.com/github/zetachang/react.rb/badges/gpa.svg)](https://codeclimate.com/github/zetachang/react.rb)

**React.rb is an [Opal Ruby](http://opalrb.org) wrapper of [React.js library](http://facebook.github.io/react/)**.

It lets you write reactive UI components, with Ruby's elegance and compiled to run in JavaScript. :heart:

## Installation

```ruby
# Gemfile
gem "react.rb"
```

and in your Opal application,

```ruby
require "opal"
require "react"

React.render(React.create_element('h1'){ "Hello World!" }, `document.body`)
```

For integration with server (Sinatra, etc), see setup of [TodoMVC](example/todos) or the [official docs](http://opalrb.org/docs/) of Opal.

## Usage

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

### React::Component

Hey, we are using Ruby, simply include `React::Component` to save your typing and have some handy methods defined.

```ruby
class HelloMessage
  include React::Component
  MSG = {great: 'Cool!', bad: 'Cheer up!'}

  define_state(:foo) { "Default greeting" }

  before_mount do
    self.foo = "#{self.foo}: #{MSG[params[:mood]]}"
  end

  after_mount :log

  def log
    puts "mounted!"
  end

  def render
    div do
      span { self.foo + " #{params[:name]}!" }
    end
  end
end

class App
  include React::Component

  def render
    present HelloMessage, name: 'John', mood: 'great'
  end
end

puts React.render_to_static_markup(React.create_element(App))

# => '<div><span>Default greeting: Cool! John!</span></div>'

React.render(React.create_element(App), `document.body`)

# mounted!
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
