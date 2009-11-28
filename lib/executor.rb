require 'arg_parser'
require 'config'
require 'file_util'

module MScript
  class Executor
    def initialize()
      @file_util = MScript::FileUtil.new
      @arg_parser = MScript::ArgParser.new
    end
    
    def execute(args)
      config = MScript::Config.new(@file_util.locate_project_directory(File.expand_path('.')))
      builds = @arg_parser.parse(args)
      
      total_builds = builds['projects'].length
      
      commands = []
      builds['projects'].each do |project|
        directory_alias = project['project']
        phase_aliases = project['phases']
        
        commands << "mvn #{config.to_phases(phase_aliases).join(' ')} -f #{File.join(config.to_directory(directory_alias), 'pom.xml')} #{builds['arguments']}"
      end
      
      # was done this way because Control+C does not kill all builds?? WTF?!
      command = commands.join(' && ')
      
      puts "------------------------------"
      puts "M Script Running....#{total_builds} build(s)" 
      puts "------------------------------"
      puts "#{command}"
      puts "------------------------------\n"
      
      system command
      
    end
    
    def show_help()
      config = MScript::Config.new(@file_util.locate_project_directory(File.expand_path('.')))
      
      puts "\n"
      puts "Project Directory: #{config.project_directory}\n\n"
      puts "Directory to Alias(es):\n---------------------------\n"
      
      longest_name = ""
      config.directory_aliases.each do |key, value|
        if (key.length > longest_name.length)
          longest_name = key
        end
      end
      
      config.directory_aliases.each do |key, value|
        number_of_dots = longest_name.length + 2 - key.length
        count = 0
        dots = ""
        while count < number_of_dots
          dots += "."
          count += 1
        end
        puts "#{key}#{dots}#{value.join(', ')}\n"
      end
      puts "\nAvailable Phase(s):\n---------------------------\n"
      config.phases.each do |key, value|
        puts "#{key}....#{value}"
      end
      puts "\n"
    end
  end
end