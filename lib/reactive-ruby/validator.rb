module React
  class Validator
    
    def self.build(&block)
      self.new.build(&block)
    end
    
    def build(&block)
      instance_eval(&block)
      self
    end

    def initialize
      @rules = {children: {required: false}}
    end

    def requires(prop_name, options = {})
      rule = options
      options[:required] = true
      @rules[prop_name] = options
    end

    def optional(prop_name, options = {})
      rule = options
      options[:required] = false
      @rules[prop_name] = options
    end
    
    def type_check(errors, error_prefix, object, klass)
      is_native = !object.respond_to?(:is_a?) rescue true
      if is_native or !object.is_a? klass
        unless klass.respond_to? :_react_param_conversion and klass._react_param_conversion object, :validate_only
          errors << "#{error_prefix} could not be converted to #{klass}" unless klass._react_param_conversion object, :validate_only
        end
      end
    end
  
    def validate(props)
      errors = []
      props.keys.each do |prop_name|
        errors <<  "Provided prop `#{prop_name}` not specified in spec"  if @rules[prop_name] == nil
      end

      props = props.select {|key| @rules.keys.include?(key) }

      # requires or not
      (@rules.keys - props.keys).each do |prop_name|
        errors << "Required prop `#{prop_name}` was not specified" if @rules[prop_name][:required]
      end
      # type checking
      props.each do |prop_name, value|
        if klass = @rules[prop_name][:type]
          is_klass_array = klass.is_a?(Array) and klass.length > 0 rescue nil
          if is_klass_array
            value_is_array_like = value.respond_to?(:each_with_index) rescue nil
            if value_is_array_like
              value.each_with_index { |ele, i| type_check(errors, "Provided prop `#{prop_name}`[#{i}]", ele, klass[0]) }
            else
              errors << "Provided prop `#{prop_name}` was not an Array"
            end
          else
            type_check(errors, "Provided prop `#{prop_name}`", value, klass)
          end
        end
      end

      # values
      props.each do |prop_name, value|
        if values = @rules[prop_name][:values]
          errors << "Value `#{value}` for prop `#{prop_name}` is not an allowed value" unless values.include?(value)
        end
      end
      
      errors
    end

    def default_props
      @rules
      .select {|key, value| value.keys.include?("default") }
      .inject({}) {|memo, (k,v)| memo[k] = v[:default]; memo}
    end
  end
end
