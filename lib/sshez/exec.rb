module Sshez  
  class Exec
    def process(args)
      # parse the params to get the options
      if args.length == 0
        args[0] = '-h'
      elsif args[0] == 'list'
        return ConfigFile.list
      elsif args[0] == 'remove'
        if args[1]
          return ConfigFile.remove(args[1])
        else
          output %Q|Select an alias to remove `sshez remove alias`.\n Use `sshez list` to list your aliases|
          puts output
          return output
        end
      end

      if (args.length < 2 || !args[1].include?("@") || args[0][0] == '-')
        if args.any? { |x| ['-h', '--help', '-l', '--list'].include?(x) }
          Params.parse(args)
          return
        elsif ['-r', "--remove"].include?(args[1]) 
          return ConfigFile.remove(args[0])
        elsif ['-v', '--version'].include?(args[0])
          puts Sshez.version
          return Sshez.version
        end
        output = %Q|Invalid input. Use -h for help|
        puts output
        return output
      end
      options = Params.parse(args)

      unless options.remove
        user, host = args[1].split("@") 
        output = ConfigFile.append(args[0], user, host, options)
        output + "Done!"
      end
    end
  end
end
