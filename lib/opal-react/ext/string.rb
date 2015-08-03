class String
  def event_camelize
    `#{self}.replace(/(^|_)([^_]+)/g, function(match, pre, word, index) {
      var capitalize = true;
      return capitalize ? word.substr(0,1).toUpperCase()+word.substr(1) : word;
    })`
  end
end