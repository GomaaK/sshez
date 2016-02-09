module Sshez
  # handles parsing the arguments to meaningful actions
  #
  # Parser.new(listener).parse(args)
  #
  class Parser
    PRINTER = PrintingManager.instance
    #
    # to create an instance pass any +Struct+ that handles the following methods
    # *  :start_exec(+Command+, +OpenStruct+(options))
    # *  :argument_error(+Command+)
    # *  :done_with_no_guarantee
    #
    attr_reader :listener

    #
    # Must have the methods mentioned above
    #
    def initialize(listener)
      @listener = listener
    end

    #
    # Return a structure describing the command and its options.
    # prints help if no args supplied
    # command is the first argument passed in the commandline
    #
    # The options specified on the command line will be collected in *options*.
    # options.file_content will contain
    # what should be added in the next step to the config file
    def parse(args)
      args[0] ||= '-h'
      command = Command::ALL[args.first]
      options = OpenStruct.new(file_content: OpenStruct.new)
      init_options_parser(options).parse!(args)
      args.delete_at(0)
      return no_command_supplied unless(command && !options.halt)
      command.args = args
      return parsing_succeeded(command, options) if command.valid?(args)
      parsing_failed(command)
    end  # parse(args)

    #
    # Initates an OptionParser with all of the possible options
    # and how to handle them
    #
    def init_options_parser(options)
      OptionParser.new do |opts|
        opts.banner = "Usage:\n"\
        "\tsshez add <alias> (role@host) [options]\n"\
        "\tsshez connect <alias>\n"\
        "\tsshez remove <alias>\n\tsshez list\n"\
        "\tsshez reset\n"
        opts.separator ''
        opts.separator 'Specific options:'
        options_for_add(opts, options)
        # signals that we are in testing mode
        opts.on('-t', '--test', 'Writes nothing') {options.test = true}
        common_options(opts, options)
      end # OptionParser.new
    end

    #
    # Returns the options specifice to the add command only
    #
    def options_for_add(opts, options)
      opts.on('-p', '--port PORT',
              'Specify a port') do |port|
        options.file_content.port_text = "  Port #{port}\n"
      end

      opts.on('-i', '--identity_file [key]',
              'Add identity') do |key_path|
        options.file_content.identity_file_text =
          "  IdentityFile #{key_path}\n"
      end

      opts.on('-b', '--batch_mode', 'Batch Mode') do
        options.file_content.batch_mode_text = "  BatchMode yes\n"
      end
    end

    #
    # Returns the standard options
    #
    def common_options(opts, options)
      opts.separator ''
      opts.separator 'Common options:'
      # Another typical switch to print the version.
      opts.on('-v', '--version', 'Show version') do
        PRINTER.print Sshez.version
        options.halt = true
      end
      opts.on('-z', '--verbose', 'Verbose Output') do
        PRINTER.verbose!
      end
      # Prints everything
      opts.on_tail('-h', '--help', 'Show this message') do
        PRINTER.print opts
        options.halt = true
      end
    end

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
