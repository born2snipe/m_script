require 'yaml'
require 'cygwin_util'


module MScript 
  CONFIG_FILENAME = 'm.yml'
  
  class Config
    	attr_reader :project_directory, :additional_args, :phases, :directory_aliases
    
    def initialize(project_directory)
      raise "Could not locate project directory" if project_directory == nil
      
      @file_util = MScript::FileUtil.new
      @cygwin_util = MScript::CygwinUtil.new
      
      @project_directory = @cygwin_util.fix_path(project_directory)
      config_file = YAML::load_file(File.join(project_directory, CONFIG_FILENAME));
      if (config_file['arguments'])
        @additional_args = config_file['arguments']
      else
        @additional_args = []
      end
      @phases = {}
      @directory_aliases = {}
      @alias_to_directory = {}
      
      raise "No phases defined in configuration file: #{CONFIG_FILENAME}" if !config_file['phases']
      config_file['phases'].each { |phase| @phases[phase[0,1]] = phase }
      dir_has_alias = []
      if (config_file['directory_mappings'])
        config_file['directory_mappings'].each do |key, value| 
          @directory_aliases[value] = [key]
          @alias_to_directory[key] = [value]
          dir_has_alias << value
        end
      end
      
      @file_util.dirs(project_directory).each do |dir|
        project_path = File.expand_path(File.join(project_directory, dir))
        if (!dir_has_alias.include?(dir) && @file_util.maven_project?(project_path))
          short_alias = @file_util.alias(dir)
          if @alias_to_directory[short_alias]
            conflicting_modules = [@alias_to_directory[short_alias], dir]
            raise "Folders #{conflicting_modules.join(' & ')} have a conflicting alias (#{short_alias}). I would recommend defining aliases for these two folders in the #{CONFIG_FILENAME} file"
          else
            @directory_aliases[dir] = [short_alias, dir]          
            @alias_to_directory[short_alias] = dir
            @alias_to_directory[dir] = dir
          end
        end
      end
      
    end
    
    def to_directory(dir_alias)
      raise ArgumentError, "Could not locate directory for alias '#{dir_alias}'" if !@alias_to_directory.has_key?(dir_alias)
      @cygwin_util.fix_path(File.join(@project_directory, @alias_to_directory[dir_alias]))
    end
    
    def to_phase(phase_alias)
      raise ArgumentError, "Could not locate phase for alias '#{phase_alias}'" if !@phases.has_key?(phase_alias)
      @phases[phase_alias]
    end
    
    def to_phases(phase_aliases)
      phases = []
      index = 0;
      while index < phase_aliases.length
        phases << to_phase(phase_aliases[index, 1])
        index += 1
      end
      phases
    end
  end
  
end