# React.rb

**React.rb is a [Opal Ruby](http://opalrb.org) wrapper of [React.js library](http://facebook.github.io/react/)**.

It let you write reactive UI component with Ruby's elegancy and compiled to run in Javascript.

## Installation

```ruby
gem `react.rb`
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

React.render_static_markup(React.create_element(HelloMessage)) # => '<div>Hello World!</div>'
```

### More complicated one

To hook into native ReactComponent life cycle, the native `this` will be passed to the class's initializer. And all corresponding life cycle methods (`componentDidMount`, etc) will be invoked on the instance with using the corresponding snake case method name.

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

puts React.render_static_markup(React.create_element(HelloMessage, name: 'John'))

# => will_mount!
# => '<div>Hello John!</div>'
```

### React::Component

Hey, we are using Ruby, simply include `React::Component` to save your typing and have some handy method defined.

```ruby
class HelloMessage
  define_state(:foo) { "Default greeting" }

  before_mount do
    self.foo = self.foo + " <3 "
  end

  def render
    div do
      span { self.foo + " Hello #{params[:name]}!" }
    end
  end
end

React.render_static_markup(React.create_element(HelloMessage, name: 'John')) # => '<div>Hello John!</div>'
```

* Callback of life cycle could be created through `before_mount`, `after_mount`, etc
* `this.props` is provided through method `self.params`
* Use class method `define_method` to create setter & getter of `this.state` for you

### Props validation

How about props validation? Inspired from [Grape API](https://github.com/intridea/grape), props validation rule could be create easily through `params` class method as below,

```ruby
class App
  params do
    requires :username, type: String
    requires :enum, values: ['foo', 'bar', 'awesome']
    requires :payload, type: Todo # yeah, a plain Ruby class
    optional :filters, type: Array[String]
    optional :flash_message, type: String, default: 'Welcome!' # no need to feed through `getDefaultProps`
  end

  def render; end
end
```

## Example

* React Tutorial: see [example/react-tutorial](example/react-tutorial), the original CommentBox example.
* TodoMVC: see [example/todos](example/todos), your beloved TodoMVC <3.

## Developing

To run the test case of the project yourself.

1. `git clone` the project
2. `bundle install`
3. `bundle exec rackup`
4. Open `http://localhost:9292` to run the spec

## Contributions

This project is still in early stage, so discussion, bug report and PR are really welcome :wink.

## Contact

[David Chang](http://github.com/zetachang)
[@zetachang](https://twitter.com/zetachang)

## License

In short, IPSqueezableViewController is available under the MIT license. See the LICENSE file for more info.
