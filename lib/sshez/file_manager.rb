require 'forwardable'
module Sshez  
  #
  # handles all the updates to the .ssh/config file
  #
  # to create an instance pass any +Struct+(listener) that handles the following methods
  # *  :argument_error(+Command+)
  # *  :done_with_no_guarantee
  # *  :permission_error
  # *  :finished_successfully
  #
  class FileManager
    extend Forwardable
    FILE_PATH = File.expand_path('~') + '/.ssh/config'
    PRINTER = PrintingManager.instance
    attr_reader :listener

    def_delegators :@listener, :argument_error
    def_delegators :@listener, :done_with_no_guarantee

    #
    # Must have the methods mentioned above
    #
    def initialize(listener)
      @listener = listener
    end

    #
    # Starts the execution of the +Command+ parsed with its options
    #
    def start_exec(command, options)
      all_args = command.args
      all_args << options
      self.send(command.name, *all_args)
    end

    private
    #
    # append an aliase for the given user@host with the options passed
    #
    def add(aliase_name, user, host, options)
      begin
        PRINTER.verbose_print "Adding\n"
        config_append = form(aliase_name, user, host, options)
        PRINTER.verbose_print config_append
        unless options.test
          file = File.open(FILE_PATH, 'a+')
          file.write(config_append)
          file.close

          # causes a bug in fedore if permission was not updated to 0600
          File.chmod(0600, FILE_PATH) 
          # system "chmod 600 #{FILE_PATH}"
        end
      rescue 
        return permission_error
      end
      PRINTER.verbose_print "to #{FILE_PATH}"
      PRINTER.print "Successfully added `#{aliase_name}` as an alias for `#{user}@#{host}`"
      PRINTER.print "try ssh #{aliase_name}"

      finish_exec
    end # append(aliase_name, user, host, options)

    #
    # returns the text that will be added to the config file
    #
    def form(aliase_name, user, host, options)
      retuned = "\n"
      retuned += "Host #{aliase_name}\n"
      retuned += "  HostName #{host}\n"
      retuned += "  User #{user}\n"
      
      options.file_content.each_pair do |key, value|
        retuned += value
      end
      retuned

    end # form(aliase_name, user, host, options)

    #
    # removes an aliase from the config file (all its occurrences will be removed too)
    #
    def remove(aliase_name, options)
      file = File.open(FILE_PATH, 'r')
      new_file = File.open(FILE_PATH+'temp', 'w')
      remove_alias_name(aliase_name, file, new_file)
      file.close
      new_file.close
      File.delete(FILE_PATH)
      File.rename(FILE_PATH + 'temp', FILE_PATH)

      # causes a bug in fedore if permission was not updated to 0600
      File.chmod(0600, FILE_PATH) 
      # system "chmod 600 #{FILE_PATH}"

      unless PRINTER.output?
        PRINTER.print "could not find host (#{aliase_name})"
      end
      finish_exec
    end # remove(aliase_name, options)

    #
    # copies the content of the file to the new file without
    # the sections concerning the alias_name
    #
    def remove_alias_name(alias_name, file, new_file)
      started_removing = false
      file.each do |line|
        not_copying = line.include?("Host #{alias_name}") || started_removing
        if not_copying
          # I will never stop till I find another host that is not the one I'm removing
          condition = (started_removing && line.include?('Host ') && !line.include?(alias_name))
          PRINTER.verbose_print line unless condition
          started_removing = !condition
        else
          # Everything else should be transfered safely to the other file
          new_file.write(line)
        end
      end
    end #remove_alias_name(alias_name, file, new_file)

    #
    # lists the aliases available in the config file
    #
    def list(options)
      file = File.open(FILE_PATH, 'r')
      servers = all_hosts_in(file)
      file.close
      if servers.empty?
        PRINTER.print 'No aliases added'
      else
        PRINTER.print 'Listing aliases:'
        servers.each{|x| PRINTER.print "\t- #{x}"}
      end
      finish_exec
    end # list(options)

    #
    # Returns all the alias names of in the file
    #
    def all_hosts_in(file)
      servers = []
      file.each do |line|
        if line.include?('Host ')
          servers << line.sub('Host', '')
        end
      end
      servers
    end
    
    #
    # Raises a permission error to the listener
    #
    def permission_error
      listener.permission_error
    end

    #
    # 
    #
    def finish_exec
      listener.finished_successfully
    end

    # private



  end # class FileManager
end