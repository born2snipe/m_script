module MScript
  class ArgParser 
    def parse(args)
      builds = {}
      projects = []
      builds['projects'] = projects
      builds['arguments'] = []

      index = 0
      while index < args.length
        if (args[index][0,1] == '-')
          builds['arguments'] << args[index]
          index += 1
        else
          projects << {'phases' => args[index], 'project' => args[index + 1]}
          index += 2
        end
      end
      
      builds
    end
  end
end