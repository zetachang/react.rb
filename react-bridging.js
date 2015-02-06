var React = require('react');

React.createClassFromBridgingClass = function(className) {
    var instance = Opal[className].$new();
    var spec = Object.create(instance);
    // We only need to rebind the *required* methods to underlying corresponing Ruby one for React.Component 
    spec.render = spec.$render;
    spec.componentWillMount = function() {
        instance.$_component_will_mount.call(instance);
    }
    spec.componentDidMount = function() {
        instance.$_component_did_mount.call(instance);
    }
    
    var component = React.createClass(spec);
    return component;
};

window.React = React;