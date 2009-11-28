require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MScript::Config do
  
  before(:each) do
     @project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'project'))
     @config = MScript::Config.new(@project_dir)
  end
  
  ##################################
  # TODO - these validation checks should be done by another class
  ##################################
  
  it "should throw an error if project directory is nil" do
    lambda { 
      MScript::Config.new(nil)
    }.should raise_error(RuntimeError, "Could not locate project directory")
  end
  
  it "should raise an error if a directory alias can not be resolved to a directory" do
     lambda { 
       @config.to_directory('doesNotExist')
     }.should raise_error(ArgumentError, "Could not locate directory for alias 'doesNotExist'")
  end

  it "should raise an error if a phase alias can not be resolved to a phase" do
    lambda { 
     @config.to_phase('doesNotExist') 
    }.should raise_error(ArgumentError, "Could not locate phase for alias 'doesNotExist'")
   end
  
   it "should raise an error if no phases are defined in the configuration file" do
     lambda { 
       project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'no-phases-defined-project'))
       config = MScript::Config.new(project_dir)
      }.should raise_error(RuntimeError, "No phases defined in configuration file: m.yml")
   end

  it "should raise an error if two folders auto-aliased and have the same alias" do
    lambda { 
      project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'conflicting-auto-alias-project'))
       MScript::Config.new(project_dir)
    }.should raise_error(RuntimeError, "Folders module1 & module2 have a conflicting alias (m). I would recommend defining aliases for these two folders in the m.yml file")
  end
  
  it "should not auto-generate folder alias for folders that do NOT contain a pom file" do
    project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'ignore-non-pom-directories'))
    config = MScript::Config.new(project_dir)
    config.directory_aliases.should == {'module2' => ['m', 'module2']}
  end
  
  it "should not require defining directory mappings in the configuration file" do
    project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'no-directory-mappings-project'))
    config = MScript::Config.new(project_dir)
    config.directory_aliases.should == {'module1' => ['m', 'module1']}
  end
  
  it "should not require defining of additional args in the configuration file" do
    project_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'fixtures', 'no-additional-args-project'))
    config = MScript::Config.new(project_dir)
    config.additional_args.should == []
  end
  
  it "should resolve to the proper phases" do
    @config.to_phases('ci').should == ['clean', 'install']
  end
  
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