## 0.3.1
*  Invoking params multiple times will append to the existing parameters

## 0.3.0
*  Depends on `sprockets < 3` thus source map can still work
*  Remove sprockets-es6 from dependency
*  Set `displayName` of component as the Ruby class name, which make it displayed better in [react-devtools](https://github.com/facebook/react-devtools)
*  Fix React::Element bridging in React Native environment (#fba2daeb)
*  React#create_element accept a native component constructor function

## 0.2.1
*  Depends on opal `~> 0.6.0`, which accidentally got loosen in previous release

## 0.2.0

*  Deprecating `jsx` helper method in component instance
*  Deprecating `React::Element.new`, use `React.create_element` instead
*  `React::Element` is now toll-free bridge to [ReactElement](http://facebook.github.io/react/docs/glossary.html#react-elements)
*  `React::Element#props` now return a `Hash` rather than a `Native`
*  `React::Element#children` now handling empty child & single child correctly
