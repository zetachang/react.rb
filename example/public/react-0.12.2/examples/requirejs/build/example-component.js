/**
 * @jsx React.DOM
 */
define([], function () {
  "use strict";

  var ExampleComponent = React.createClass({displayName: 'ExampleComponent',

    render:function(){
      return React.DOM.div(null, "Simple RequireJS Example");
    }

  });

  return ExampleComponent;
});