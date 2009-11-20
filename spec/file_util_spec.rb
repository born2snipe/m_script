require File.join(File.dirname(__FILE__), 'spec_helper')

describe MScript::FileUtil do
  
  before(:each) do
      @fixtures = File.join(File.dirname(__FILE__), '..', 'fixtures')
      @util = MScript::FileUtil.new
      @project_dir = File.expand_path(File.join(@fixtures, 'project'))
  end
  
  it "should look recursively up the directory structure for the yml file" do
    dir = File.expand_path(File.join(@fixtures, 'project', 'nested'))
    @util.locate_project_directory(dir).should == @project_dir
  end
  
  it "should return the current directory if it contains the yml file" do
    @util.locate_project_directory(@project_dir).should == @project_dir
  end
  
  it "should return nil if a project directory could not be located" do
        @util.locate_project_directory(@fixtures).should == nil
  end
  
end