require 'yaml'

module MScript 
  CONFIG_FILENAME = 'm.yml'
  
  class CygwinUtil
    def fix_path(path) 
      path.gsub(/\/cygdrive\/(.)\/(.*)/, '\1:/\2')
    end
  end
  
  class FileUtil
    def locate_project_directory(directory)
      current_directory = directory
      while !File.exist?(File.join(current_directory, CONFIG_FILENAME)) && current_directory != File.dirname(current_directory)
        current_directory = File.dirname(current_directory)
      end
      if (current_directory == File.dirname(current_directory))
        nil
      else
        current_directory
      end
    end
    
    def alias(directory) 
      if (directory.index('-'))
        dir_alias = ""
        directory.split('-').each { |x| dir_alias += x[0,1]}
        dir_alias
      else
        directory[0,1]
      end
    end
    
    def maven_project?(directory)
      File.exist?(File.join(directory, 'pom.xml'))
    end
  end
  
  class Config
    	attr_reader :project_directory, :additional_args, :phases, :directory_aliases
    
    def initialize(project_directory)
      raise "Could not locate project configuration file: #{CONFIG_FILENAME} in directory: #{project_directory}" if project_directory == nil
      @file_util = MScript::FileUtil.new
      @project_directory = project_directory
      config_file = YAML::load_file(File.join(project_directory, CONFIG_FILENAME));
      if (config_file['arguments'])
        @additional_args = config_file['arguments']
      else
        @additional_args = []
      end
      @phases = {}
      @directory_aliases = {}
      
      raise "No phases defined in configuration file: #{CONFIG_FILENAME}" if !config_file['phases']
      config_file['phases'].each { |phase| @phases[phase[0,1]] = phase }
      dir_has_alias = []
      if (config_file['directory_mappings'])
        config_file['directory_mappings'].each do |key, value| 
          @directory_aliases[value] = [key]
          dir_has_alias << value
        end
      end
      
      Dir.new(project_directory).entries.each do |dir|
        directory = File.expand_path(File.join(project_directory, dir))
        if dir != '..' && dir != '.' && !dir_has_alias.include?(dir) && File.directory?(directory) && @file_util.maven_project?(directory)
          @directory_aliases[dir] = [@file_util.alias(dir), dir]          
        end
      end
      
      @alias_to_directory = {}
      @directory_aliases.each do |key, value|
        value.each { |alias_name| @alias_to_directory[alias_name] = key}
      end
    end
    
    def to_directory(dir_alias)
      raise ArgumentError, "Could not locate directory for alias '#{dir_alias}'" if !@alias_to_directory.has_key?(dir_alias)
      File.join(@project_directory, @alias_to_directory[dir_alias])
    end
    
    def to_phase(phase_alias)
      raise ArgumentError, "Could not locate phase for alias '#{phase_alias}'" if !@phases.has_key?(phase_alias)
      @phases[phase_alias]
    end
  end
  
end