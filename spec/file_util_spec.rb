require File.join(File.dirname(__FILE__), 'spec_helper')

describe MScript::FileUtil do
  
  before(:each) do
      @fixtures = File.join(File.dirname(__FILE__), '..', 'fixtures')
      @util = MScript::FileUtil.new
      @project_dir = File.expand_path(File.join(@fixtures, 'project'))
  end
  
  it "should return false if the folder does not contain a pom file" do
    @util.maven_project?(@fixtures).should == false
  end
  
  it "should return true if the folder contains a pom file" do
    @util.maven_project?(File.join(@project_dir, 'module')).should == true
  end
  
  it "should generate an alias based on the delimiter of the folder name" do
    @util.alias('module-2').should == 'm2'
  end
  
  it "should an alias from the give directory" do
    @util.alias('module').should == 'm'
  end
  
  it "should return nil if the current directory does not exist" do
    @util.locate_project_directory('doesNotExist').should == nil
  end
  
  it "should look recursively up the directory structure for the yml file" do
    dir = File.expand_path(File.join(@fixtures, 'project', 'module'))
    @util.locate_project_directory(dir).should == @project_dir
  end
  
  it "should return the current directory if it contains the yml file" do
    @util.locate_project_directory(@project_dir).should == @project_dir
  end
  
  it "should return nil if a project directory could not be located" do
        @util.locate_project_directory(@fixtures).should == nil
  end
  
end