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
      options.file_content = OpenStruct.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: sshez alias (role@host|-r) [options]"

        opts.separator ""
        opts.separator "Specific options:"

        # Mandatory argument.
        opts.on("-p", "--port PORT",
                "Specify a port") do |port|
          options.port = port
          options.file_content.port_text = "  Port #{options.port}\n"
        end

        # Optional argument; multi-line description.
        opts.on("-i", "--identity_file [key]",
                "Add identity") do |key_path|
          options.identity_file = key_path
          options.file_content.identity_file_text = "  IdentityFile #{options.identity_file}\n"
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
        end

        # Another typical switch to print the version.
        opts.on_tail("--version", "Show version") do
          puts ::Version.join('.')
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
      output += config_append
      unless options.test
        file_path = File.expand_path('~')+"/.ssh/config"
        file = File.open(file_path, "a+")
        file.write(config_append)
        file.close
      end
      output += "to #{file_path}\n"
      output += "try ssh #{name} \n"
      
      output
    end

    def self.form(name, user, host, options)
      retuned = "\n"
      retuned += "Host #{name}\n"
      retuned += "  HostName #{host}\n"
      retuned += "  User #{user}\n"
      
      options.file_content.each_pair do |key, value|
        retuned += value
      end
      retuned

    end

    def self.remove(name)
      output = ""
      started_removing = false
      file_path = File.expand_path('~')+"/.ssh/config"
      file = File.open(file_path, "r")
      new_file = File.open(file_path + "temp", "w")

      file.each do |line|

        if line.include?("Host #{name}")|| started_removing

          if started_removing && line.include?("Host ") && !line.include?(name)
            started_removing = false
          else
            output += line
            started_removing = true
          end

        else
          new_file.write(line)
        end

      end
      file.close
      new_file.close
      File.delete(file_path)
      File.rename(file_path + "temp", file_path)

      if output.empty?
        return "could not find host (#{name})"
      else
        return output
      end
      
    end
    


  end

  class Exec

    def process(args)
      # parse the params to get the options
      if (args.length < 2 || !args[1].include?("@") || args[0][0] == '-')
        if args[0] == "-h"
         Params.parse(args)
         return nil
        elsif ['-r', "--remove"].include?(args[1]) 
          return ConfigFile.remove(args[0])
        end
        output = %Q|Invalid input
        Use -h for help|
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
