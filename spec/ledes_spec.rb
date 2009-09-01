require File.dirname(__FILE__) + '/spec_helper'  

describe Ledes::LedesFile do
  
  describe :creating_a_new_ledes_with_valid_data

  before :each do
    @ledes = Ledes::LedesFile.new
  end

  it "should accept a text file as input" do
    @ledes.should_not be_nil
  end

  it "should have Ledes Lines " do
    # test.txt should have 7 lines
    @ledes.line_items.should have(7).things    
  end

  it "should have a header" do
    @ledes.header.should_not be_nil
  end
  
  it "should have many columns" do
    @ledes.fields.should_not be_nil
  end
  
  it "should not have any errors" do
    @ledes.errors.should == false
    @ledes.error_messages.should have(0).things
  end

  # not sure how I feel about this test.  I think technically it's fine, but it 
  # is sort of doing two test; one for nothing longer, and to ensure the longest 
  # is as long as the header.  
  # prolly fine I guess.  Sort of the same thing
  it "should not contain any items whom has more fields than the header; the longest should be equal to the length of the header" do
    longest = 0
    @ledes.line_items.each {|line| longest = line.body_array.length if line.body_array.length > longest }
    is_the_same = longest == @ledes.fields.length ? true : false
    is_the_same.should be_true
  end

  it "should return an error if the first line of the Ledes files is not LEDES1992B[]" do
    ledes = Ledes::LedesFile.new("#{File.dirname(__FILE__)}/../test_bad.txt")
    ledes.errors.should be_true
  end
  
  # more to come once we figure out more of what this should do.
  it "should respond to the move_to_database method with two keys as parameters" do
    @ledes.should respond_to(:move_to_database)    
  end

  it "should find the two models that have been passed in a symbols to the move_to_database method" do
    class One
    end

    class Two
    end
    
    @ledes.move_to_database(:one, :two)
    @ledes.errors.should be_false
    @ledes.error_messages.should have(0).things
  end

  it "should return two error messages and errors should be true if the passed models do not exist" do
    @ledes.move_to_database(:three, :four)
    @ledes.errors.should be_true
    @ledes.error_messages.should have(2).things
  end
end

