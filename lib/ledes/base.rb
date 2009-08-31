module Ledes
  module Base    
      # simply pass in an error message to set errors to true and build the error 
      # message array
      def set_error_message message
        defined?(@error_messages) ? @error_messages << message : @error_messages = [message]
        @errors = true        
      end

      # used to calculate the length in KB of the passed string
      # might move to the LedesTools module
      def calculate_string_size_in_kb string
        total_bytes = 0
        string.each_byte {|b| total_bytes += 1}
        result = total_bytes.to_f / 1024.to_f
      end
  end
end
