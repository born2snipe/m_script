require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MScript::CygwinUtil do
  
  before(:each) do
      @util = MScript::CygwinUtil.new
  end
  
  it "should fix path if cygdrive is found and capture remaining folders" do
    @util.fix_path("/cygdrive/c/projects").should == 'c:/projects'
  end
  
  it "should not alter path if cygdrive is NOT found" do
    @util.fix_path('c:/projects').should == 'c:/projects'
  end
  
end