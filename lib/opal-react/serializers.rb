[BigDecimal, Bignum, FalseClass, Fixnum, Float, Integer, NilClass, String, Symbol, Time, TrueClass].each do |klass|
  klass.send(:define_method, :react_serializer) do 
    as_json
  end
end

Array.send(:define_method, :react_serializer) do 
  self.collect { |e| e.react_serializer }.as_json
end

Hash.send(:define_method, :react_serializer) do
  Hash[*self.collect { |key, value| [key, value.react_serializer] }.flatten(1)].as_json
end
