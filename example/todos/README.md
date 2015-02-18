# react.rb-todos

Modify from original version of [Opal-Todos](https://github.com/opal/opal-todos)

## Running

Get dependencies:

```
$ bundle install
```

Run the sprockets based server for auto-compiling:

```
$ bundle exec rackup
```

Open `http://localhost:9292` in the browser.

## Code Overview

Opal comes with sprockets support built in, so using rack we can have an
easy to boot build system to handle all opal dependencies. If you look
in `index.html.erb`, you will see a call to `javascript_include_tag`
which acts just like the rails tag helper. This will include our
`application.rb` file, and all of its dependencies. Each file will be included
in a seperate `<script>..</script>` tag to make navigating the code in a
web browser easier.

### Router

`TodoAppView` use router provided by [Vienna](https://github.com/opal/vienna)

### Model

Use model layer provided by [Vienna](https://github.com/opal/vienna) which provide basic support of local storage and update notification.
