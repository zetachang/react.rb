## edge (upcoming 0.2.0)

*  Deprecating `jsx` helper
*  Deprecating `React::Element.new`, use `React.create_element` instead
*  `React::Element` is now toll-free bridge to [ReactElement](http://facebook.github.io/react/docs/glossary.html#react-elements)
*  `React::Element#props` now return a `Hash` rather than a `Native`
*  `React::Element#children` now handling empty child & single child correctly