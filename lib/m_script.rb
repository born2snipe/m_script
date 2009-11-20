require 'yaml'

module MScript 
  
  class CygwinUtil
    def fix_path(path) 
      path.gsub(/\/cygdrive\/(.)\/(.*)/, '\1:/\2')
    end
  end
  
  class FileUtil
    def locate_project_directory(directory)
      current_directory = directory
      while !File.exist?(File.join(current_directory, 'm.yml')) && current_directory != File.dirname(current_directory)
        current_directory = File.dirname(current_directory)
      end
      if (current_directory == File.dirname(current_directory))
        nil
      else
        current_directory
      end
    end
  end
  
end