module Ledes
  class LedesFile
    
    attr_accessor :header, :line_items, :fields, :errors, :error_messages, :file
    
    def initialize(file = "#{RAILS_ROOT}/test.txt")
      @version = "0.0.1"
      @file = file
      @errors = false
      @error_messages = []
      @body = IO.read @file
      @line_items = get_lines @body
      @fields = column_names @line_items.first.body  
      check_length_of_columns_vs_lines
    end

    private

    # so, checking that none of our lines is longer than our header is really 
    # a job for our Ledes object, so this was moved here
    def check_length_of_columns_vs_lines
      longest = 0
      self.line_items.each {|line| longest = line.body_array.length if line.body_array.length > longest }
      set_error_message("Column lengths do not match") unless self.fields.length == longest
    end
    
    # lame o method for just getting the column names
    def column_names string
      string.split("|").flatten
    end
    
    # parses the body and extracts the lines, cleaning them up if needed
    def get_lines(string)
      result = Array.new
      lines = string.split('[]')
      unless lines.first == "LEDES1998B"
        set_error_message("First line of Ledes file is not \"LEDES1992B[]\" #{lines.first}")
      else
        # delete the first line since it is correct and we don't need it anymore
        lines.delete_at(0) 
      end
      lines.delete(lines.last) if lines.last.blank? # sometimes we get a blank line at the end
      @header = lines.first
      # build ledes_line objects 
      build_line_item_array lines
    end

    # bam
    def build_line_item_array lines
      lines.map {|line|Ledes::LedesLine.new(line,  @header)}
    end
  end
end

