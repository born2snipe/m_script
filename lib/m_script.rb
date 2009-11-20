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
  end
  
  class Config
    	attr_reader :project_directory, :additional_args, :phases, :directory_aliases
    
    def initialize(project_directory)
      raise "Could not locate project configuration file: #{CONFIG_FILENAME} in directory: #{project_directory}" if project_directory == nil
      @project_directory = project_directory
      config_file = YAML::load_file(File.join(project_directory, CONFIG_FILENAME));
      @additional_args = config_file['arguments']
      @phases = {}
      @directory_aliases = {}
      config_file['phases'].each { |phase| @phases[phase[0,1]] = phase }
      
      Dir.new(project_directory).entries.each do |dir|
        if dir != '..' && dir != '.' && File.directory?(File.expand_path(File.join(project_directory, dir)))
          if (dir.index('-'))
            dir_alias = ""
            dir.split('-').each { |x| dir_alias += x[0,1]}
            @directory_aliases[dir] = [dir_alias, dir]
          else
            @directory_aliases[dir] = [dir[0,1], dir]
          end
        end
      end
      
      @alias_to_directory = {}
      @directory_aliases.each do |key, value|
        value.each { |alias_name| @alias_to_directory[alias_name] = key}
      end
    end
    
    def to_directory(dir_alias)
      File.join(@project_directory, @alias_to_directory[dir_alias])
    end
    
    def to_phase(phase_alias)
      @phases[phase_alias]
    end
  end
  
end