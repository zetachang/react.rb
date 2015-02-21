module React
  class Validator
    def self.build(&block)
      validator = self.new
      validator.instance_eval(&block)
      validator
    end

    def initialize
      @rules = {}
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

    def validate(props)
      #debugger
      errors = []
      props.keys.each do |prop_name|
        errors <<  "Provided prop `#{prop_name}` not specified in spec"  if @rules[prop_name] == nil
      end

      props = props.select {|key| @rules.keys.include?(key) }

      # requires or not
      (@rules.keys - props.keys).each do |prop_name|
        errors << "Required prop `#{prop_name}` was not specified" if @rules[prop_name][:required]
      end

      # type
      props.each do |prop_name, value|
        if klass = @rules[prop_name][:type]
          if klass.is_a?(Array)
            errors <<  "Provided prop `#{prop_name}` was not an Array of the specified type `#{klass[0]}`" unless value.all?{ |ele| ele.is_a?(klass[0]) }
          else
            errors <<  "Provided prop `#{prop_name}` was not the specified type `#{klass}`" unless value.is_a?(klass)
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
