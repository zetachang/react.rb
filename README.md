# Reactive-Ruby

**Reactive-Ruby is an [Opal Ruby](http://opalrb.org) wrapper of [React.js library](http://facebook.github.io/react/)**.

It lets you write reactive UI components, with Ruby's elegance using the tried and true React.js engine. :heart:

This fork of the original react.rb gem is a work in progress.  Currently it is being used in a large rails app, so until a better guide can be written we will just assume you will use it a rails app too.  However the gem itself has no dependency on rails, and there are people using the gem in other environments.

## Quick Overview

A react app is built from one or more trees of components.  A react component can live side by side with other non-react html. A react component is just like a rails view or a partial.  Reactive-Ruby takes advantage of this by letting you add Reactive-Ruby components as views, and call them directly from your controller like any other view.

Components are first rendered to HTML on the server (called pre-rendering) this is no different from what happens when your ERB or HAML templates are translated to HTML.  

A copy of the react engine, and your components follows the rendered HTML to the browser, and then when a user interacts with the page, it is updated on the client.

The beauty is you now have one markup description, written in the same language as your server code, that works both as the HTML template and as an interactive component.

By design Reactive-Ruby allows reactive components  to be easily added to existing Rails projects, as well in new development. 


## Installation and setup

```ruby
gem 'reactive-ruby'

# the next three gems are for integration with rails (TODO - package these up as a reactive-rails gem)

gem 'therubyracer', platforms: :ruby # you need this for prerendering to work
gem 'react-rails', git: "https://github.com/catprintlabs/react-rails.git", :branch => 'isomorphic-methods-support'  
gem 'opal-rails'                      
```

Your react components will go into the `app/views/components/` directory of your rails app.

In addition within your views directory you need a  `components.rb` manifest file like this:

```
# app/views/components.rb
require 'opal'
require 'react'
require 'reactive-ruby'
require_tree './components'
``` 

This pulls in the files that will be used both for server side and browser rendering.

Then your `assets/javascript/application.rb` file looks like this:

```
#assets/javascript/application.rb
# only put files that are browser side only.
require 'react_ujs'  # this is required and is part of the prerendering system
require 'components' # this pulls in your components from the components.rb manifest file      
```

Okay that is your setup.

Now for a simple component.  We are going to render this from the `show` method of the home controller. By default we want
our component name to match (convention over configuration.)  So the component will be the "Show" class, of the "Home" module, 
of the Components module.

```ruby

# app/views/components/home.rb

module Components 
  class Home

    include React::Component   # will create a new component named Home
    
    export_component           # export the component name into the javascript space 
  
    def render  
      puts "Rendering my first component!"
      "hello"                  # render "hello" 
    end
    
  end
end
```

Components work just like views so put this in your home controller
```ruby
# controllers/home_controller.rb
class HomeController < ApplicationController
  def show
    render_component  # by default render_component will use the controller name to find the appropriate component
  end
end
```

Make sure your routes file has a route to your home#show method, and you have done a bundle install.  Fire up your development server and you should see "hello world" displayed.

Open up the js console in the browser and you will see a log showing what went on during the rendering.


## TODOS / Work arounds / Issues

* Documentation
* Should load the RubyRacer, or at least report an error if the RubyRacer is not present
* Get everything to autoload what it needs (i.e. much less config setup)

## Developing

To run the above examples project yourself:

1. `git clone` the project
2. `cd example/tutorial`
2. `bundle install`
3. `bundle exec rackup`
4. Open `http://localhost`

## Contributions

This project is still in early stage, so discussion, bug report and PR are really welcome :wink:.
We check in often at https://gitter.im/zetachang/react.rb ask for @catmando as David is on leave right now. 

## Contact

We check in often at https://gitter.im/zetachang/react.rb ask for @catmando.

## License

In short, React.rb is available under the MIT license. See the LICENSE file for more info.
