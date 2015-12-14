module Sshez  
  class ConfigFile
    FILE_PATH = File.expand_path('~') + "/.ssh/config"

    def self.append(name, user, host, options)
      output =  "Adding\n"
      config_append = form(name, user, host, options)
      output += config_append
      unless options.test
        file = File.open(FILE_PATH, "a+")
        file.write(config_append)
        file.close
        puts "Successfully added `#{name}` as an alias for `#{user}@#{host}`"
        system "chmod 600 #{FILE_PATH}"
      end
      output += "to #{FILE_PATH}\n"
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
      file = File.open(FILE_PATH, "r")
      new_file = File.open(FILE_PATH+"temp", "w")
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
      File.delete(FILE_PATH)
      File.rename(FILE_PATH + "temp", FILE_PATH)
      system "chmod 600 #{FILE_PATH}"

      if output.empty?
        return "could not find host (#{name})"
      else
        return output
      end
    end

    def self.list
      file = File.open(FILE_PATH, "r")
      servers = []
      file.each do |line|
        if line.include?("Host ")
          servers << line.sub('Host', '')
        end
      end
      file.close
      if servers.empty?
        puts "No aliases added"
      else
        puts "Listing aliases:"
        servers.each{|x| puts "\t- #{x}"}
      end
    end
  end
end