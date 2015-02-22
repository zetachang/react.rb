class Hash
  def shallow_to_n
    hash = `{}`
    self.map do |key, value|
       `hash[#{key}] = #{value}`
    end
    hash
  end
end
