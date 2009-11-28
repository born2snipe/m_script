require 'arg_parser'
require 'config'
require 'file_util'

module MScript
  class Executor
    def initialize()
      @file_util = MScript::FileUtil.new
      @arg_parser = MScript::ArgParser.new
      @config = MScript::Config.new(@file_util.locate_project_directory(File.expand_path('.')))
    end
    
    def execute(args)
      builds = @arg_parser.parse(args)
      
      total_builds = builds['projects'].length
      
      commands = []
      builds['projects'].each do |project|
        directory = @config.to_directory(project['project'])
        phases = @config.to_phases(project['phases'])
        
        commands << "mvn #{phases.join(' ')} -f #{File.join(directory, 'pom.xml')} #{builds['arguments']}"
      end
      
      # was done this way because Control+C does not kill all builds?? WTF?!
      result = true
      i = 0
      while result && i < commands.length
        command = commands[i]      
        puts "------------------------------"
        puts "M Script Running....#{i+1}/#{total_builds} build(s)" 
        puts "------------------------------"
        puts "#{command}"
        puts "------------------------------\n"
      
        result = system command
        i += 1
      end
    end
    
    def show_help()
      puts "\n"
      puts "Project Directory: #{@config.project_directory}\n\n"
      puts "Directory to Alias(es):\n---------------------------\n"
      
      longest_name = ""
      names = []
      @config.directory_aliases.each do |key, value|
        if (key.length > longest_name.length)
          longest_name = key
        end
        names << key
      end
      
      names.sort { |a, b| a <=> b}.each do |directory|
        aliases = @config.directory_aliases[directory]
        number_of_dots = longest_name.length + 2 - directory.length
        count = 0
        dots = ""
        while count < number_of_dots
          dots += "."
          count += 1
        end
        puts "#{directory}#{dots}#{aliases.join(', ')}\n"
      end
      
      puts "\nAvailable Phase(s):\n---------------------------\n"
      @config.phases.each do |key, value|
        puts "#{key}....#{value}"
      end
      puts "\n"
    end
  end
end