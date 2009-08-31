module Ledes
  class LedesLine
    attr_accessor :body, :fields, :number_of_columns, :errors, :error_messages,  :line_body, :line_type, :body_array, :header_array, :header, :line

    # sets variables and runs initial validations
    def initialize(line, header)
      @line = line
      @header = header
      @errors = false
      @error_messages = []
      @header_array = self.header.strip.split("|")
      @body = self.line.strip.delete("[]")
      @body_array = @body.strip.split("|")
      @fields = get_columns(@body_array, @header_array)
      @line_type = find_column_value("EXP/FEE/INV_ADJ_TYPE")
      # starts the validations
      run_verification
    end
    
    # returns the value of column in the line item
    def find_column_value name
      index = self.header_array.index(name)    
      @fields[index]
    end

    private  

    # all actual verification of the data occurs here.
    # we just fire off the different components
    def run_verification
      verify_data_format # runs through what we have and makes sure teh values are in the correct format
      verify_dependencies # makes sure that any 'optional' columns have any dependency columns present
      verify_order # finally, all columns must be in a specific order 
    end
    
    # verify the the actual line values are in the correct format according 
    # to the ledes specification.
    def verify_data_format
      index = 0
      @body_array.freeze
      @header_array.each do |column|      
        matched_column = @@all_fields.find {|f| f[:name] == column}
        if matched_column
          set_error_message("Column #{matched_column[:name]} is not in the correct format") unless verify_data_value matched_column, @body_array[index]
        end
        index += 1
      end
    end
    
    # all ledes columns must be in a specific order.  The :number hash key in the @@optional_fields and @@required_fields
    # contains the index the field be.
    def verify_order
      # well build an array containing the elements we should have
      array_to_compare = build_sorted_header_array
      # put the elements in order and compare it.
      compare_header_array_order(array_to_compare.sort {|a, b| a[:number] <=> b[:number]})
    end 

    # iterates through the sorted array and our header array making sure
    # they are in the same order.  If not, errors is set to true and we
    # put an error message in our errors array
    def compare_header_array_order(array_to_compare)
      index = 0
      @header_array.each do |column|
        set_error_message("Columns are out of order #{array_to_compare[index][:name]}") unless array_to_compare[index][:name] == column
        index += 1
      end
    end

    # builds an array based on our optional and required fields that has
    # the same elements our header_array has.  We can then sort it and
    # get the order our header SHOULD be in
    def build_sorted_header_array
      array_to_compare = []
      self.header_array.each do |name|
        field = @@all_fields.find {|field| field[:name] == name}
        array_to_compare << field unless field.blank?
      end
      array_to_compare
    end
    
    # todo: still need to implament a couple of the depends_on's
    def verify_dependencies 
      needed_fields = find_optional_fields
      
      needed_fields.each do |field| 
        set_error_message("Missing column - #{field[:name]}") unless check_field_has_data(field[:name])
      end
      
    end
    
    # this finds all the obvious matches in the toptional fields array
    # but also gets teh ones like !(IF||EF).
    # right now, we just manually specify things.  Maybe in the future a 
    # non manual method can be contrived.

    def find_optional_fields
      fields = @@optional_fields.find_all {|f| f[:depends_on] == self.line_type}
      # anything but an IE and IF's get this
      unless self.line_type == "IF" || "IE"
        fields << @@optional_fields.find {|f| f[:depends_on] == "!(IF || IE)"} 
      end
      fields
    end
    # simply returns boolean if data exists for a given column
    def check_field_has_data field
      find_column_value(field).blank? ? false : true
    end
    
    # big bad method that grabs the correct regex for the column data type
    # runs it against the value, and sets an error if nessessary.
    def verify_data_value hash, column
      valid = case hash[:format]
              when "Date * 8 YYYYMMDD"
                true  unless (column  =~ /^(\d{8})$/ ).nil?
              when "Character * 30"
                true unless column.length >= 30
              when "Character * 20"
                true unless column.to_s.length >= 20
              when "Character * 10"
                true unless column.length >= 10
              when "Character * 2"
                true unless column.length >= 2
              when "Currency * 12.4"
                true unless (column =~ /(^[0-9]{0,12}\.[0-9]{0,4}$|^[0-9]{0,12}$)/).nil?
              when "Currency * 10.4"
                true unless (column =~ /(^[0-9]{0,10}\.[0-9]{0,4}$|^[0-9]{0,10}$)/).nil? 
              when "Numeric * 10.4" 
                true unless (column =~ /(^[0-9]{0,10}\.[0-9]{0,4}$|^[0-9]{0,10}$)/).nil? 
              when "Character * 15 KB" 
                true unless calculate_string_size_in_kb(column) >= 15
              else
                true
              end
      valid
    end
    
    # simply builds an array of our columns based on the header and our body.  
    # puts a blank a new String object if no value is present (which is ok)
    def get_columns(body, header)
      columns = []
      count = header.length
      0.upto count do |c|
        value = body[c] ? body[c].strip : String.new
        columns << value
      end
      columns
    end    

    # below here is where we defind our class variables of the required and 
    # optional fields
    @@required_fields = [
                         {
                           :name =>  "INVOICE_DATE",
                           :number => 1,
                           :format => "Date * 8 YYYYMMDD"
                         },
                         {
                           :name => "INVOICE_NUMBER",
                           :number => 2,
                           :format => "Character * 20"
                         },
                         {
                           :name => "CLIENT_ID",
                           :number => 3,
                           :format => "Character * 20"
                         },
                         {
                           :name => "LAW_FIRM_MATTER_ID",
                           :number => 4,
                           :format => "Character * 20"
                         },
                         {
                           :name => "INVOICE_TOTAL",
                           :number => 5,
                           :format => "Currency * 12.4"
                         },
                         {
                           :name => "BILLING_START_DATE",
                           :number => 6,
                           :format => "Date * 8 YYYYMMDD"
                         },
                         {
                           :name => "BILLING_END_DATE",
                           :number => 7,
                           :format => "Date * 8 YYYYMMDD"
                         },
                         {
                           :name => "LINE_ITEM_NUMBER",
                           :number => 9,
                           :format => "Character * 20"
                         },
                         {
                           :name => "EXP/FEE/INV_ADJ_TYPE",
                           :number => 10,
                           :format => "Character * 2"
                         },
                         {
                           :name => "LINE_ITEM_TOTAL",
                           :number => 13,
                           :format => "Currency * 10.4"
                         },
                         {
                           :name => "LINE_ITEM_DATE",
                           :number => 14,
                           :format => "Date * 8 YYYYMMDD"
                         },
                         {
                           :name => "LAW_FIRM_ID",
                           :number => 20,
                           :format => "Character * 20"
                         },
                        ]
    @@optional_fields = [
                         {
                           :name => "INVOICE_DESCRIPTION",
                           :number => 8,
                           :format => "Character * 15 KB",
                           :depends_on => nil
                         },
                         {
                           :name => "LINE_ITEM_NUMBER_OF_UNITS",
                           :number => 11,
                           :format => "Numeric * 10.4",
                           :depends_on => "!(IF || IE)"
                         },
                         {
                           :name => "LINE_ITEM_ADJUSTMENT_AMOUNT",
                           :number => 12,
                           :format => "Currency * 10.4",
                           :depends_on => nil
                         },
                         {
                           :name => "LINE_ITEM_TASK_CODE",
                           :number => 15,
                           :format => "Character * 20",
                           :depends_on => "F"
                         },
                         {
                           :name => "LINE_ITEM_EXPENSE_CODE",
                           :number => 16,
                           :format => "Character * 20",
                           :depends_on => "E"
                         },
                         {
                           :name => "LINE_ITEM_ACTIVITY_CODE",
                           :number => 17,
                           :format => "Character * 20",
                           :depends_on => "F"
                         },
                         {
                           :name => "TIMEKEEPER_ID",
                           :number => 18,
                           :format => "Character * 20",
                           :depends_on => "F"
                         },                             
                         {
                           :name => "LINE_ITEM_DESCRIPTION",
                           :number => 19,
                           :format => "Character * 15 KB",
                           :depends_on => "F"
                         },
                         {
                           :name => "LINE_ITEM_UNIT_COST",
                           :number => 21,
                           :format => "Currency * 10.4",
                           :depends_on => "!(IF || IE)"
                         },
                         {
                           :name => "TIMEKEEPER_NAME",
                           :number => 22,
                           :format => "Character * 30",
                           :depends_on => "F"
                         },
                         {
                           :name => "TIMEKEEPER_CLASSIFICATION",
                           :number => 23,
                           :format => "Character * 10",
                           :depends_on => "F"
                         },
                         {
                           :name => "CLIENT_MATTER_ID",
                           :number => 24,
                           :format => "Character * 20",
                           :depends_on => "!Matter" # does not assign matter numbers
                         }
                        ]
    # provides a simple variable to iterate through all the fields
    @@all_fields = @@optional_fields + @@required_fields
  end
end
