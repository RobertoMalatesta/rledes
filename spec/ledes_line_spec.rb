require File.dirname(__FILE__) + '/spec_helper'  

describe Ledes::LedesLine do
  
  # builds a string of 15361 characters that should fail validation on fields requiring < 15kb 
  def build_bad_description
    description = String.new
    15361.times {|letter| description += "a"}
    description
  end

  describe :creating_a_new_ledes_line_with_with_good_data
  
  before :each do
    @header = "INVOICE_DATE|INVOICE_NUMBER|CLIENT_ID|LAW_FIRM_MATTER_ID|INVOICE_TOTAL|BILLING_START_DATE|BILLING_END_DATE|INVOICE_DESCRIPTION|LINE_ITEM_NUMBER|EXP/FEE/INV_ADJ_TYPE|LINE_ITEM_NUMBER_OF_UNITS|LINE_ITEM_ADJUSTMENT_AMOUNT|LINE_ITEM_TOTAL|LINE_ITEM_DATE|LINE_ITEM_TASK_CODE|LINE_ITEM_EXPENSE_CODE|LINE_ITEM_ACTIVITY_CODE|TIMEKEEPER_ID|LINE_ITEM_DESCRIPTION|LAW_FIRM_ID|LINE_ITEM_UNIT_COST|TIMEKEEPER_NAME|TIMEKEEPER_CLASSIFICATION|CLIENT_MATTER_ID"
    
    line_body = "19990225|96542|00711|0528|2934.45|19990101|19990131|For services rendered|1|F|2.00|70|630|19990115|L510||A102|22547|Research Attorney's fees, Set off claim|24-6437381|350|Arnsley, Robert|PT|423-987"
    @line = Ledes::LedesLine.new(line_body, @header)
  end

  after :each do
    @line = nil
  end
  
  it "should create a new instance when passed a body and header array" do
    @line.should_not be_nil
  end

  it "should have an array of columns" do
    @line.fields.class.should == Array
    @line.fields.should have_at_least(2).things
  end

  it "should return the correct type" do
    @line.line_type.should == "F"
  end
  
  it "should respond to errors" do
    @line.should respond_to(:errors)
  end

  it "should not have any errors the passed fields and line is valid" do
    @line.errors.should be(false)
  end
  
  it "should return the value of a field when passed the column name" do
    @line.find_column_value("CLIENT_ID").should_not be_nil
  end

  it "should split it's body into an array for each field"do
    @line.body_array.class.should == Array
  end

  it "should contain the line as text in the body attribute" do
    @line.body.should == "19990225|96542|00711|0528|2934.45|19990101|19990131|For services rendered|1|F|2.00|70|630|19990115|L510||A102|22547|Research Attorney's fees, Set off claim|24-6437381|350|Arnsley, Robert|PT|423-987"
  end

  it "should not have any error messages" do
    @line.error_messages.class.should == Array
    @line.error_messages.should have(0).things
  end

  it "should not let the user access the verify methods directly " do
    lambda {@line.verify}.should raise_error
    lambda {@line.verify_optional}.should raise_error
    lambda {@line.verify_dependencies}.should raise_error
    lambda {@line.verify_data_format}.should raise_error
    lambda {@line.get_columns}.should raise_error
  end
  
  it "be able to convert the size of string to kilobytes correctly" do
    @line.calculate_string_size_in_kb("hi my name is john").should ==  0.017578125
  end
  
  describe :creating_a_new_line_with_invalid_data

  # begin of required fields

  it "should have error if columns are not correctly fomatted" do
    line_body = "19225|96542|00711|0528|2934.45|19901|190131|For services rendered|1|F|2.00|70|630|19990df|L510||A102|22547|Research Attorney's fees, Set off claim|24-6437381|350|Arnsley, Robert|PT|423-987"
    @bad_line = Ledes::LedesLine.new(line_body, @header)
    @bad_line.errors.should be_true
    @bad_line.error_messages.should have(4).things
  end

  it "should have an error message when the invoice date is incorrectly formatted" do
    data = "1990225|96542|00711|0528|2934.45|19990101|19990131|For services rendered|2|F|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column INVOICE_DATE is not in the correct format"
  end
  
  it "should have an error message when the client id is incorrectly formatted" do    
    data = "19990225|96542|0000000000034343434343443434343434000000000000000000000000711|0528|2934.45|19990101|19990131|For services rendered|2|F|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column CLIENT_ID is not in the correct format"
  end
  
  it "should have an error message when the Law firm matter id is incorrectly formatted" do    
    data = "19990225|96542|0711|000000000000000000000000000000000000528|2934.45|19990101|19990131|For services rendered|2|F|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LAW_FIRM_MATTER_ID is not in the correct format"
  end

  it "should have an error message when the Invoice Total is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.40005|19990101|19990131|For services rendered|2|F|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column INVOICE_TOTAL is not in the correct format"
  end  
  
  it "should have an error message when the Billing start date is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.45|198990101|19990131|For services rendered|2|F|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column BILLING_START_DATE is not in the correct format"
  end
  
  it "should have an error message when the line_item_number is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|For services rendered|0000000000000000000000000000000000000000000000000000000000000000|F|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_NUMBER is not in the correct format"
  end
  
  it "should have an error message when the EXP/FEE/INV/ADJ_TYPE is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|For services rendered|00|FDD|2.00|0|700|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column EXP/FEE/INV_ADJ_TYPE is not in the correct format"
  end

  it "should have an error message when the line_item_total is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|For services rendered|00|F|2.00|0|700T|19990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_TOTAL is not in the correct format"
  end

  it "should have an error message when the line_item_date is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|For services rendered|00|F|2.00|0|700|1d990115|L510||A102|22547|Research attorney's fees, Trial pleading|24-6437381|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_DATE is not in the correct format"
  end

  it "should have an error message when the law_firm_id is incorrectly formatted" do    
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|For services rendered|00|F|2.00|0|700|19900115|L510||A102|22547|Research attorney's fees, Trial pleading|24-64373810000000000000000000000000000000000000000|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LAW_FIRM_ID is not in the correct format"
  end
  # end required fields

  # begin optional fields
  it "should have an error message when the invoice_description is incorrectly formatted" do    
    description = build_bad_description
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|#{description}|00|F|2.00|0|700|19900115|L510||A102|22547|description goes here|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column INVOICE_DESCRIPTION is not in the correct format"
  end

  it "should have an error message when the line_item_description is incorrectly formatted" do    
    description = build_bad_description
    data = "19990225|96542|000711|0528|2934.45|19990101|19990131|description|00|F|2.00|0|700|19900115|L510||A102|22547|#{description}|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_DESCRIPTION is not in the correct format"
  end

  it "should have an error message when the client_id is incorrectly formatted" do    
    data = "19990225|96542|0000000000000000000000000000000000000000000000711|0528|2934.45|19990101|19990131|description|00|F|2.00|0|700|19900115|L510||A102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column CLIENT_ID is not in the correct format"
  end

  it "should have an error message when the law_firm_matter_id is incorrectly formatted" do    
    data = "19990225|96542|00711|00000000000000000000000000000000000000000000528|2934.45|19990101|19990131|description|00|F|2.00|0|700|19900115|L510||A102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LAW_FIRM_MATTER_ID is not in the correct format"
  end

  it "should have an error message when the line_item_number_of_units is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200000000000000000000000000.50000|0|700|19900115|L510||A102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_NUMBER_OF_UNITS is not in the correct format"
  end

  it "should have an error message when the line_item_adjustment_amount is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|100000000000000000|700|19900115|L510||A102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_ADJUSTMENT_AMOUNT is not in the correct format"
  end

  it "should have an error message when the line_item_task_code is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|10000|700|19900115|Ldfdfdfdfdfdfdfdfdfdfdfdfddfdfdf510||A102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_TASK_CODE is not in the correct format"
  end

  it "should have an error message when the line_item_expense_code is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|100|700|19900115|L510|fdfadfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf|dfA102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_EXPENSE_CODE is not in the correct format"
  end

  it "should have an error message when the line_item_activity_code is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|10|700|19900115|L510||A321321321321321321321321321231102|22547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column LINE_ITEM_ACTIVITY_CODE is not in the correct format"
  end

  it "should have an error message when the TIMEKEEPER_ID is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|10|700|19900115|L510||A32|2123132132132132132132112133122132312313213212547|description|24-64373810|350|Arnsley, Robert|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column TIMEKEEPER_ID is not in the correct format"
  end

  it "should have an error message when the timekeeper_name is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|10|700|19900115|L510||A32|2212547|description|24-64373810|350|Arnsley, Robertasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf|PT|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column TIMEKEEPER_NAME is not in the correct format"
  end

  it "should have an error message when the timekeeper_classification is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|10|700|19900115|L510||A32|2212547|description|24-64373810|350|Arnsley, Robert|PTdsfasdfasdfasdfasfasfafsfdadfasfasdfasdfasdfasfdasdfasdfasdfasfdasf|423-987"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column TIMEKEEPER_CLASSIFICATION is not in the correct format"
  end

  it "should have an error message when the client_matter_id is incorrectly formatted" do    
    data = "19990225|96542|00711|000528|2934.45|19990101|19990131|description|00|F|200.00|10|700|19900115|L510||A32|2212547|description|24-64373810|350|Arnsley, Robert|PT|423-98732132132132312321321321321321321321321"
    line_bad = Ledes::LedesLine.new data, @header
    line_bad.error_messages.should have(1).thing
    line_bad.error_messages.first.should == "Column CLIENT_MATTER_ID is not in the correct format"
  end

  describe :validating_the_order_of_columns
  # this kinda sucks to test, but mainly if we don't have any errors,
  # we're good to go
  it "should validate that the columns are in the correct order" do
    @line.errors.should be_false
  end
end
    @header = "INVOICE_DATE|INVOICE_NUMBER|CLIENT_ID|LAW_FIRM_MATTER_ID|INVOICE_TOTAL|BILLING_START_DATE|BILLING_END_DATE|INVOICE_DESCRIPTION|LINE_ITEM_NUMBER|EXP/FEE/INV_ADJ_TYPE|LINE_ITEM_NUMBER_OF_UNITS|LINE_ITEM_ADJUSTMENT_AMOUNT|LINE_ITEM_TOTAL|LINE_ITEM_DATE|LINE_ITEM_TASK_CODE|LINE_ITEM_EXPENSE_CODE|LINE_ITEM_ACTIVITY_CODE|TIMEKEEPER_ID|LINE_ITEM_DESCRIPTION|LAW_FIRM_ID|LINE_ITEM_UNIT_COST|TIMEKEEPER_NAME|TIMEKEEPER_CLASSIFICATION|CLIENT_MATTER_ID"
