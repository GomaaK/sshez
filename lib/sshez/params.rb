module Sshez  
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
        opts.banner = "Usage:\n\tsshez <alias> (role@host|-r) [options]\n\tsshez remove <alias>\n\tsshez list"

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

        opts.on("-t", "--test", "Writes nothing") do
          options.test = true
        end

        opts.separator ""
        opts.separator "Common options:"

        opts.on("-l", "--list", "List aliases") do
          Sshez::ConfigFile.list
          return
        end

        # Another typical switch to print the version.
        opts.on("-v", "--version", "Show version") do
          puts Sshez.version
          return
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          puts "\n"
        end
      end

      opt_parser.parse!(args)
      options
    end  # parse()
  end  # class Params
end