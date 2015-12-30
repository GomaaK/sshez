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
    # prints only if verbose set to true
    #
    def verbose_print(text)
      @output += %Q|#{text}\n|
      puts text if @verbose
      @output
    end

    #
    # Did we print anything?
    #
    def output?
      !@output.empty?
    end

    #
    # getter for all the printing log
    #
    def output
      @output
    end

    #
    # Let the flooding begin!
    #
    def verbose!
      @verbose = true
    end

    #
    # Resets the printer for testing purposes
    #
    def clear!
      @output = ""
      @verbose = false
    end

  end
end