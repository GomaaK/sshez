require "sshez/version"
require 'optparse'
require 'ostruct'

module Sshez
  # Your code goes here...
  

  class Params

    #
    # Return a structure describing the options.
    #
    def self.parse(args)
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: sshez name user@ip [options]"

        opts.separator ""
        opts.separator "Specific options:"

        # Mandatory argument.
        opts.on("-p", "--port PORT",
                "Specify a port") do |port|
          options.port = port
        end

        # Optional argument; multi-line description.
        opts.on("-i", "--identity_file [key]",
                "Add identity") do |key_path|
          options.identity_file = key_path
        end

        opts.on("-r", "--remove", "Remove handle") do
          options.remove = true
        end

        opts.on("-t", "--test", "writes nothing") do
          options.test = true
        end

        opts.separator ""
        opts.separator "Common options:"

        # No argument, shows at tail.  This will print an options summary.
        # Try it and see!
        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts ::Version.join('.')
          exit
        end
      end

      opt_parser.parse!(args)
      options
    end  # parse()

  end  # class Params

  class ConfigFile
    def self.append(name, user, host, options)
      output =  "Adding\n"
      config_append = form(name, user, host, options)
      output += "" + config_append
      unless options.test
        file_path = File.expand_path('~')+"/.ssh/config"
        file = File.open(file_path, "a+")
        file.write(config_append)
        file.close
      end
      output += "to #{file_path}\n"
      
      output
    end

    def self.form(name, user, host, options)
      retuned = %Q|Host #{name}
        HostName #{host}
        User #{user}
      |
      if options.port
        retuned += %Q|  Port #{options.port}
        |
      end

      if options.identity_file
        retuned += %Q|  IdentityFile #{options.identity_file}
        |
      end
      retuned

    end
    


  end

  class Exec

    def process(args)
      # parse the params to get the options
      if args.length < 2 || !args[1].include?("@") 
        output = %Q|Invalid input
        Use -h for help|
        return output
      end
      options = Params.parse(args)


      if options.remove
        "Not implemented :("
      else
        user, host = args[1].split("@") 
        output = ConfigFile.append(args[0], user, host, options)
        output + "Done!"
      end

    end

  end

end
