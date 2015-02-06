/**
 * @jsx React.DOM
 */
require(['build/example-component'], function(ExampleComponent){
  "use strict";

  React.renderComponent(ExampleComponent(null ), document.getElementById('container'));
});