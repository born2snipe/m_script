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
      config_file['phases'].each { |phase_alias, phase| @phases[phase_alias] = phase }
      
      mapped_directories_to_aliases = {}
      mapped_aliases_to_directories = {}
      
      if (config_file['directory_mappings'])
        config_file['directory_mappings'].each do |key, value|
          mapped_directories_to_aliases[value] = [key]
          mapped_aliases_to_directories[key] = value
          index_directory_aliases(value, [key])
        end
      end
      
      @file_util.dirs(project_directory).each do |dir|
        project_path = File.expand_path(File.join(project_directory, dir))
        if (!mapped_directories_to_aliases[dir] && @file_util.maven_project?(project_path))
          short_alias = @file_util.alias(dir)
          if @alias_to_directory[short_alias]
            conflicting_modules = [@alias_to_directory[short_alias], dir]
            raise "Folders #{conflicting_modules.join(' & ')} have a conflicting alias (#{short_alias}). I would recommend defining aliases for these two folders in the #{CONFIG_FILENAME} file"
          else
            index_directory_aliases(dir, [short_alias, dir])
          end
        end
      end
      
    end
    
    def index_directory_aliases(directory, aliases)
      @directory_aliases[directory] = aliases
      aliases.each do |alias_name|
        @alias_to_directory[alias_name] = directory
      end
    end
    
    def to_directory(dir_alias)
      directory = @alias_to_directory[dir_alias]
      if (directory)
        @cygwin_util.fix_path(File.join(@project_directory, directory))
      else
        directory
      end
    end
    
    def to_phase(phase_alias)
      @phases[phase_alias]
    end
    
    def to_phases(phase_aliases)
      phases = []
      index = 0;
      match = true
      while index < phase_aliases.length && match
        phase = to_phase(phase_aliases[index, 1])
        if (phase)
          phases << phase
        else
          match = false
        end
        index += 1
      end
      if match
        phases
      else
        []
      end
    end
  end
  
end