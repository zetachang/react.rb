class String
  def event_camelize
    `#{self}.replace(/(^|_)([^_]+)/g, function(match, pre, word, index) {
      var capitalize = true;
      return capitalize ? word.substr(0,1).toUpperCase()+word.substr(1) : word;
    })`
  end

  # 'class_name' => 'className'
  def lower_camelize
    # TODO Could be implemented more efficiently
    words = self.split("_")
    result = [words.first]
    result.concat(words[1..-1].map {|word| word[0].upcase + word[1..-1] })
    result.join("")
  end
  
  # 'className' => 'class_name'
  def underscore
    return `self.replace(/[A-Z]/g, function(){
       return '_' + arguments[0].toLowerCase();
     });`
  end
end
