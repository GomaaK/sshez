module Sshez  
  # handles parsing the arguments to meaningful actions
  class Parser < Struct.new(:listener)

    PRINTER = PrintingManager.instance

    #
    # Return a structure describing the options.
    #
    def parse(args)
      # prit help if no args supplied
      if args.length == 0
        args[0] = '-h'
      end
      # command is the first argument passed in the commandline
      command = Command::ALL[args.first]
      # The options specified on the command line will be collected in *options*.
      # We set default values here.
      options = OpenStruct.new
      # file_content will contain what should be added in the next step to the config file
      options.file_content = OpenStruct.new

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage:\n\tsshez add <alias> (role@host) [options]\n\tsshez remove <alias>\n\tsshez list"

        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-p", "--port PORT",
                "Specify a port") do |port|
          options.file_content.port_text = "  Port #{port}\n"
        end

        opts.on("-i", "--identity_file [key]",
                "Add identity") do |key_path|
          options.file_content.identity_file_text = "  IdentityFile #{options.identity_file}\n"
        end
        
        opts.on("-b", "--batch_mode", "Batch Mode") do
          options.file_content.batch_mode_text = "  BatchMode yes\n"
        end

        # signals that we are in testing mode
        opts.on("-t", "--test", "Writes nothing") do
          options.test = true
        end

        opts.separator ""
        opts.separator "Common options:"

        # Another typical switch to print the version.
        opts.on("-v", "--version", "Show version") do
          PRINTER.print Sshez.version
          options.halt = true
        end

        opts.on("-z", "--verbose", "Verbose Output") do
          PRINTER.verbose!
        end

        # Prints everything
        opts.on_tail("-h", "--help", "Show this message") do
          PRINTER.print opts
          options.halt = true
        end
        
      end # OptionParser.new

      # this will remove the matched options from the args array
      opt_parser.parse!(args)

      args.delete_at(0)
      if command && !options.halt
        if command.valid?(args)
          command.args = args
          parsing_succeeded(command, options)
        else
          command.args = args
          parsing_failed(command)
        end
      else
        no_command_supplied
      end

      
    end  # parse(args)


    #
    # Keeps track of the which command the user called
    #  
    class Command
      # no one should create a command except from this class!
      #
      # name: can only be one of these [add, remove, list]
      # validator: a proc that returns true only if the input is valid for the command
      # args: the args it self!
      # correct_format: the way the user should run this command
      # args_processor: (optional) a proc that will process the args before setting them
      #
      def initialize(name, validator, correct_format, args_processor=nil)
        @name = name
        @validator = validator
        @args = []
        @correct_format = correct_format
        @args_processor = args_processor
      end
      #
      # a list of all commands
      #
      ALL = {
        "add" => Command.new("add", (Proc.new { |args| (args.length == 2) && (args[1].include?("@")) }), "sshez add <alias> (role@host) [options]", (Proc.new {|alias_name, role_host| [alias_name] + role_host.split('@') })),
        "remove" => Command.new("remove", (Proc.new { |args| args.length == 1 }), "sshez remove <alias>"),
        "list" => Command.new("list", (Proc.new { |args| args.empty? }), "sshez list")
      }
      #
      # processes the value passed if a processor was defined
      #
      def args=(value)
        if @args_processor
          @args = @args_processor.call(value)
        else
          @args = value
        end
      end

      def name
        @name
      end

      def args
        @args
      end
      #
      # validateds the args using the proc previously defined
      #
      def valid?(args)
        @validator.call(args)
      end
      #
      # returns the text that should appear for a user in case of invalid input for this command
      #
      def error
        "Invalid input (#{args.join(',')}) for #{@name}.\n#{@correct_format}"
      end

    end # class Command


    private

      #
      # Triggers the listener with the +Command+ and options parsed
      #
      def parsing_succeeded(command, options)
        listener.start_exec(command, options)
      end


      #
      # Triggers the listener with the failure of the +Command+
      #
      def parsing_failed(command)
        listener.argument_error(command)
      end

      #
      # Handles when there is no command (maybe only an option is given)
      #
      def no_command_supplied
        listener.done_with_no_guarantee
      end

    # private
  end  # class Parser
end
