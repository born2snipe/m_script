module MScript
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
    
    def dirs(directory)
      dirs = []
      Dir.new(directory).entries.each do |dir|
        if File.directory?(File.expand_path(File.join(directory, dir))) && dir != '..' && dir != '.'
          dirs << dir
        end
      end
      dirs
    end
  end
end