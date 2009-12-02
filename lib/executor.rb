require 'arg_parser'
require 'config'
require 'file_util'

module MScript
  class Executor
    def initialize()
      @file_util = MScript::FileUtil.new
      @arg_parser = MScript::ArgParser.new
      project_directory = @file_util.locate_project_directory(File.expand_path('.'))
      if (project_directory)
        @config = MScript::Config.new(project_directory)
      end
    end
    
    def execute(args)
      if (!@config)
        puts "Appears to not be a MScript project. Could not locate the #{CONFIG_FILENAME} configuration file"
      else
        begin
          builds = @arg_parser.parse(args)
      
          total_builds = builds['projects'].length
      
          commands = []
          builds['projects'].each do |project|
            dir_alias = project['project']
            directory = @config.to_directory(dir_alias)
            raise ArgumentError, "Could not locate directory for directory alias '#{dir_alias}'" if directory == nil
            
            phase_alias = project['phases']
            phases = @config.to_phases(phase_alias)
            raise ArgumentError, "Could not locate phase for alias '#{phase_alias}'" if phases.length == 0
        
            commands << "mvn #{phases.join(' ')} -f #{File.join(directory, 'pom.xml')} #{builds['arguments']}"
          end
      
          startTime = Time.now
          result = true
          i = 0
          while result && i < commands.length
            command = commands[i]      
            puts "------------------------------------------------------------------------"
            puts "M Script Running....#{i+1}/#{total_builds} build(s)" 
            puts "------------------------------------------------------------------------"
            puts "#{command}"
            puts "------------------------------------------------------------------------\n"
      
            result = system command
            i += 1
          end
          puts "------------------------------------------------------------------------"
          puts "Ran #{i} of #{total_builds} build(s) in #{Time.now - startTime} second(s)"
          puts "------------------------------------------------------------------------"
        rescue ArgumentError => argError
          puts "------------------------------------------------------------------------"
          puts "M Script Error"
          puts "------------------------------------------------------------------------"
          puts "#{argError}\n\nType 'm' for the help menu and view the available aliases"
          puts "------------------------------------------------------------------------"
        end
      end
    end
    
    def show_help()
      if (!@config)
        puts "Appears to not be a MScript project. Could not locate the #{CONFIG_FILENAME} configuration file"
      else
        puts "\n"
        puts "Project Directory: #{@config.project_directory}\n\n"
        puts "Directory to Alias(es):\n------------------------------------------------------------------------\n"
      
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
      
        puts "\nAvailable Phase(s):\n------------------------------------------------------------------------\n"
        @config.phases.each do |key, value|
          puts "#{key}....#{value}"
        end
        puts "\n"
      end
    end
  end
end