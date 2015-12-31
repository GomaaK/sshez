module Sshez
  #
  # Keeps track of the which command the user called
  #  
  class Command
    # Exposes the name and arguments
    attr_reader :name, :args
    # no one should create a command except from this class!
    #
    # name: can only be one of these [add, remove, list]
    # validator: a proc that returns true only if the input is valid 
    # for the command
    # args: the args it self!
    # correct_format: the way the user should run this command
    # args_processor: (optional) a proc that will process the args 
    # before setting them
    #
    def initialize(name, validator, correct_format, args_processor = nil)
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
      'add' => Command.new('add',
        (proc { |args| (args.length == 2) && (args[1].include?('@')) }),
        'sshez add <alias> (role@host) [options]',
        (proc { |alias_name, role_host| [alias_name] + role_host.split('@') })),
      'remove' => Command.new('remove', (proc { |args| args.length == 1 }),
        'sshez remove <alias>'),
      'list' => Command.new('list', (proc { |args| args.empty? }), 'sshez list')
    }
    #
    # processes the value passed if a processor was defined
    #
    def args=(value)
      @args = @args_processor ? @args_processor.call(value) : value
    end
    #
    # validateds the args using the proc previously defined
    #
    def valid?(args)
      @validator.call(args)
    end
    #
    # returns the text that should appear for a user 
    # in case of invalid input for this command
    #
    def error
      "Invalid input (#{args.join(',')}) for #{@name}.\n#{@correct_format}"
    end

  end # class Command
end