require 'singleton'

module Sshez
  # Just a printing service that keeps track by all its output
  # Mainly used for testing purposes
  class PrintingManager
    include Singleton

    def initialize
      @output = ""
      @verbose = false
    end

    # adds to output then prints
    def print(text)
      @output += %Q|#{text}\n|
      puts text
      @output
    end # print(text)

    # 
    def verbose_print(text)
      @output += %Q|#{text}\n|
      puts text if @verbose
      @output
    end

    def output?
      !@output.empty?
    end

    def output
      @output
    end

    def verbose!
      @verbose = true
    end

    def clear!
      @output = ""
      @verbose = false
    end

  end
end