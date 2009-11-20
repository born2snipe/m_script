require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MScript::Config do
  
  before(:each) do
      @project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'project'))
      @config = MScript::Config.new(@project_dir)
  end
  
  # it "should throw an error if project directory is nil" do
  #       MScript::Config.new(nil).should raise_error
  #   end
  
  # it "should raise an error if a directory alias can not be resolved to a directory" do
  #     @config.to_directory('doesNotExist').should raise_error(ArgumentError, "Could not locate directory for alias 'doesNotExist'")
  #   end
  #   
  #   it "should raise an error if a phase alias can not be resolved to a phase" do
  #     @config.to_phase('doesNotExist').should raise_error(ArgumentError, "Could not locate phase for alias 'doesNotExist'")
  #   end
  
  it "should resolve to proper phase when an alias is given" do
    @config.to_phase('i').should == 'install'
  end
  
  it "should give the proper directory when an alias is given" do
    @config.to_directory('m').should == File.join(@project_dir, 'module')
  end
  
  it "should calculate alias for directories" do
    @config.directory_aliases.should == {'module'=>['m', 'module'], 'other-module'=>['om', 'other-module'], 'really-really-really-really-really-long-folder-name'=>['long']}
  end
  
  it "should return a map of phases with thier aliases" do
    @config.phases.should == {'c' => 'clean', 'i' => 'install'}
  end
  
  it "should return a list of additional args" do
    @config.additional_args.should == ['-ff']
  end
  
  it "should not change the project directory" do
    @config.project_directory.should == @project_dir
  end
  
end