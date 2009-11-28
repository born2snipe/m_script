require File.join(File.dirname(__FILE__), 'spec_helper')

describe MScript::ArgParser do
  
  before(:each) do
      @parser = MScript::ArgParser.new
      @builds = {}
      @projects = []
      @arguments = []
      @builds['projects'] = @projects
      @builds['arguments'] = @arguments
  end

  it "should add all projects" do
    @projects << {'phases' => 'ci', 'project' => 'f'}
    @projects << {'phases' => 'c', 'project' => 'fp'}
    
    @parser.parse(['ci', 'f', 'c', 'fp']).should == @builds
  end


  it "should add all additional args" do
    @projects << {'phases' => 'ci', 'project' => 'f'}
    @builds['arguments'] = ['-o', '-Dmaven.test.skip']
    
    @parser.parse(['ci', 'f', '-o', '-Dmaven.test.skip']).should == @builds
  end


  it "should parse when a single project is given, with additional arg" do
    @projects << {'phases' => 'ci', 'project' => 'f'}
    @builds['arguments'] = ['-o']
    
    @parser.parse(['ci', 'f', '-o']).should == @builds
  end

  
  it "should parse when a single project is given" do
    @projects << {'phases' => 'ci', 'project' => 'f'}
    
    @parser.parse(['ci', 'f']).should == @builds
  end
  
end