class DebugFormatter < ::Opal::RSpec::TextFormatter
  # Include the stack trace
  def dump_failure_info(example)
    exception = example.execution_result[:exception]
    exception_class_name = exception.class.name.to_s
    red "#{long_padding}#{exception_class_name}:"
    message_lines = exception.message.to_s.split("\n")
    message_lines << exception.backtrace
    message_lines.each { |line| red "#{long_padding}  #{line}" }
  end      
end  
