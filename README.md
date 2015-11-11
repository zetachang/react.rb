# React.rb / Reactive-Ruby

[![Join the chat at https://gitter.im/zetachang/react.rb](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/zetachang/react.rb?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/zetachang/react.rb.svg)](https://travis-ci.org/zetachang/react.rb)
[![Code Climate](https://codeclimate.com/github/zetachang/react.rb/badges/gpa.svg)](https://codeclimate.com/github/zetachang/react.rb)

**React.rb is an [Opal Ruby](http://opalrb.org) wrapper of
[React.js library](http://facebook.github.io/react/)**.

It lets you write reactive UI components, with Ruby's elegance using the tried
and true React.js engine. :heart:

### What's this Reactive Ruby?

Reactive Ruby started as a fork of the original react.rb gem, and has since been
merged back into react.rb's master branch. It aims to take react.rb a few steps
further by embracing it's 'Ruby-ness'.

Reactive-Ruby is maturing, but is still a work in progress. Currently it is
being used in a large rails app. However the gem itself has no dependency on
rails, and there are people using the gem in other environments.

Stable react.rb can be found in the
[0-3-stable](https://github.com/zetachang/react.rb/tree/0-3-stable) branch.

## Quick Overview

A react app is built from one or more trees of components.  React components can
live side by side with other non-react html and javascript. A react component is
just like a rails view or a partial.  Reactive-Ruby takes advantage of these
features by letting you add Reactive-Ruby components as views, and call them
directly from your controller like any other view.

By design Reactive-Ruby allows reactive components  to be easily added to
existing Rails projects, as well in new development.

Components are first rendered to HTML on the server (called pre-rendering) this
is no different from what happens when your ERB or HAML templates are translated
to HTML.

A copy of the react engine, and your components follows the rendered HTML to the
browser, and then when a user interacts with the page, it is updated on the
client.

The beauty is you now have one markup description, written in the same language
as your server code, that works both as the HTML template and as an interactive
component.

See the [wiki](https://github.com/zetachang/react.rb/wiki) for more details.

## Using React.rb with Rails

### Installation

In your Gemfile:

```ruby
gem 'reactive-ruby'
gem 'react-rails'
gem 'opal-rails'
gem 'therubyracer', platforms: :ruby # Required for prerendering
```

Run `bundle install` and restart your rails server.

### Both Client & Server Side Assets (Components)

Your react components will go into the `app/views/components/` directory of your
rails app.

Within your `app/views` directory you need to create a `components.rb` manifest.
Files required in `app/views/components.rb` will be made available to the server
side rendering system as well as the browser.

```
# app/views/components.rb
require 'opal'
require 'reactive-ruby'
require_tree './components'
```

### Client Side Assets

In `assets/javascript/application.rb` require your components manifest as well
as any additional browser only assets.

```
# assets/javascript/application.rb
# Require files that are browser side only.

# Make components available by requiring your components.rb manifest.
require 'components'

# 'react_ujs' tells react in the browser to mount rendered components.
require 'react_ujs'

# Finally, require your other javascript assets. jQuery for example...
require 'jquery'      # You need both these files to access jQuery from Opal.
require 'opal-jquery' # They must be in this order.
```

### Rendering Components

Components may be rendered directly from a controller action by simply following
a naming convention. To render a component from the `home#show` action, create
component class `Components::Home::Show`:

```ruby
# app/views/components/home/show.rb
module Components
  module Home
    class Show
      include React::Component # will create a new component named Show

      optional_param :say_hello_to

      def render
        puts "Rendering my first component!"

        # render "hello" with optional 'say_hello_to' param
        "hello #{say_hello_to if say_hello_to}"
      end
    end
  end
end
```

Call `render_component` in the controller action passing in any params (React
props), to render the component:

```ruby
# controllers/home_controller.rb
class HomeController < ApplicationController
  def show
    # render_component uses the controller name to find the 'show' component.
    render_component say_hello_to: params[:say_hello_to] 
  end
end
```

Make sure your routes file has a route to your home#show action. Visit that
route in your browser and you should see 'Hello' rendered.

Open up the js console in the browser and you will see a log showing what went
on during rendering.

Have a look at the sources in the console, and notice your ruby code is there,
and you can set break points etc.

### Changing the top level component name and search path

You can control the top level component name and search path.

You can specify the component name explicitly in the `render_component` method.
`render_component "Blatz` will search the for a component class named `Blatz`
regardless of the controller method.

Searching for components normally works like this:  Given a controller named
"Foo" then the component should be either in the `Components::Foo` module, the
`Components` module (no controller - useful if you have just a couple of shared
components) or just the outer scope (i.e. `Module`) which is useful for small
apps.

Saying `render_component "::Blatz"` will only search the outer scope, while
`"::Foo::Blatz"` will look only in the module `Foo` for a class named `Blatz`.


## Integration with Sinatra

See the [sinatra example](https://github.com/zetachang/react.rb/tree/master/example/sinatra-tutorial).

## Contextual Code

Sometimes it may be necessary to run code only on the server or only in the
browser. To execute code only during server side rendering:

```ruby
if React::IsomorphicHelpers.on_opal_server?
  puts 'Hello from the server'
end
```

To execute code only in the browser:

```ruby
if React::IsomorphicHelpers.on_opal_client?
  puts 'Hello from the browser'
end
```

## Typical Problems

`Uncaught TypeError: Cannot read property 'toUpperCase' of undefined`  This
means the thing you are trying to render is not actually a react component.
Often is because the top level component name is wrong.  For example if you are
in controller Foo and the method is `bar`, but you have named the component
Foo::Bars then you would see this message.

## Turning off Prerendering

Sometimes its handy to switch off prerendering.  Add `?no_prerender=1` ... to
your url.


## TODOS / Work arounds / Issues

* Documentation
* Should load the RubyRacer, or at least report an error if the RubyRacer is not
  present
* Get everything to autoload what it needs (i.e. much less config setup)

## Developing

To run the above examples project yourself:

1. `git clone` the project
2. `cd example/tutorial`
2. `bundle install`
3. `bundle exec rackup`
4. Open `http://localhost`

## Testing

1. Run `bundle exec rake test_app` to generate a dummy test app.
2. `bundle exec rake`

## Contributions

This project is still in early stage, so discussion, bug report and PR are
really welcome :wink:.  We check in often at
https://gitter.im/zetachang/react.rb ask for @catmando as David is on leave
right now.

## Contact

We check in often at https://gitter.im/zetachang/react.rb ask for @catmando.

## License

In short, React.rb is available under the MIT license. See the LICENSE file for
more info.
