# React.rb / Reactive-Ruby

[![Join the chat at https://gitter.im/zetachang/react.rb](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/zetachang/react.rb?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/zetachang/react.rb.svg)](https://travis-ci.org/zetachang/react.rb)
[![Code Climate](https://codeclimate.com/github/zetachang/react.rb/badges/gpa.svg)](https://codeclimate.com/github/zetachang/react.rb)
[![Gem Version](https://badge.fury.io/rb/reactive-ruby.svg)](https://badge.fury.io/rb/reactive-ruby)

**React.rb is an [Opal Ruby](http://opalrb.org) wrapper of
[React.js library](http://facebook.github.io/react/)**.

It lets you write reactive UI components, with Ruby's elegance using the tried
and true React.js engine. :heart:

[**Visit reactrb.org For The Full Story**](https://reactrb.org)

### Important current react.rb gem users please [read this!](#Road-Map)

## Installation 

Install the gem, or load the js library

+ add gem 'reactive-ruby' to your gem file or
+ gem install reactive-ruby or
+ install or load via cdn [inline-reactive-ruby](https://github.com/reactive-ruby/inline-reactive-ruby)

For gem installation its highly recommended to read [the getting started section at reactrb.org](http://reactrb.org/docs/getting-started.html)

## Quick Overview

React.rb components are ruby classes that inherit from `React::Component::Base` or include `React::Component`.

`React::Component` provides a complete DSL to generate html, and event handlers, and has full set of class macros to define states, parameters, and lifecycle callbacks.

Each react component class has a render method that generates the markup for that component.

Each react component class defines a new **tag** in the DSL that works just like built-in html tags, so react components can render other react components.

As events occur, components update their state, which causes them to rerender, and perhaps pass new parameters to lower level components, thus causing them to rerender.  

Under the hood the actual work is effeciently done by the [React.js](http://facebook.github.io/react/) engine. 

React.rb components are *isomorphic* meaning they can run on the server as well as the client.  This means that the initial expansion of the component tree to markup is done server side, just like ERB, or HAML templates.   Then the same code runs on the client and will respond to any events.   

React.rb integrates well with Rails, Sinatra, and simple static sites, and can be added to existing web pages very easily, or it can be used to deliver complete websites.

## Why ?

+ *Single Language:*  Use Ruby everywhere, no JS, markup languages, or JSX
+ *Powerful DSL:* Describe HTML and event handlers with a minimum of fuss
+ *Ruby Goodness:* Use all the features of Ruby to create reusable, maintainable UI code
+ *React Simplicity:* Nothing is taken away from the React.js model
+ *Enhanced Features:* Enhanced parameter and state management and other new features
+ *Plays well with Others:* Works with other frameworks, Rails, Sinatra or in static web pages

# Problems, Questions, Issues

+ [Stack Overflow](http://stackoverflow.com/questions/tagged/react.rb) tag `react.rb` for specific problems.
+ [Gitter.im](https://gitter.im/zetachang/react.rb) for general questions, discussion, and interactive help.
+ [Github Issues](https://github.com/zetachang/react.rb/issues) for bugs, feature enhancements, etc.
+ 

# Road Map

The original react.rb gem is still available as the [0-3-stable branch.](https://github.com/zetachang/react.rb/tree/0-3-stable)

Many new features, bug fixes, and improvements are incoporated in the reactive-ruby.gem built currently on the [0-7-stable branch.](https://github.com/zetachang/react.rb/tree/0-7-stable)

Our plan is to do one more upgrade on the reactive-ruby gem which will be designated version 0.8.0.

From 0.9.0 and beyond we will return to using the react.rb gem for releases, and reactive-ruby will be a meta gem that depends only on react.rb >= 0.9.x.

Version 0.9.0 of react.rb will **not** be 100% backward compatible with 0.3.0 so its very important to begin your upgrade process now by upgrading to 0.7.0.

Please let us know either at [Gitter.im](https://gitter.im/zetachang/react.rb) or [via an issue](https://github.com/zetachang/react.rb/issues) if you have specific concerns with the upgrade from 0.3.0 to 0.9.0.

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
https://gitter.im/zetachang/react.rb 


## License

In short, React.rb is available under the MIT license. See the LICENSE file for
more info.
