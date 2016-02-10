module Sshez
  #
  # Our main class
  # This will #process the command of the user
  #
  # Sshez::Runner.new.process(ARGV)
  #
  # Acts as the listener that the +Exec+ needs
  # *  :argument_error(+Command+)
  # *  :done_with_no_guarantee
  # *  :permission_error
  # *  :finished_successfully
  #
  #
  #
  class Runner
    PRINTER = PrintingManager.instance

    #
    # Main method of the application
    # takes un processed ARGS and pass it to our parser to start our processing
    #
    def process(args)
      parser = Parser.new(Exec.new(self))
      parser.parse(args)
      PRINTER.output
    end

    #
    # We've finished everything successfully
    #
    def finished_successfully
      PRINTER.print 'Terminated Successfully!'
    end

    #
    # Handles when the config file could not be accessed due to a problem in permissions
    #
    def permission_error
      PRINTER.print "Premission denied!\nPlease check your ~/.ssh/config permissions then try again."
    end

    #
    # Returns the appropriate error messages to the given command
    #
    def argument_error(command)
      PRINTER.print(command.error)
    end

    #
    # When no valid command was supplied (maybe only an option)
    #
    def done_with_no_guarantee
      unless PRINTER.output?
        PRINTER.print('Invalid input. Use -h for help')
      end
    end

  end # class Runner
end
