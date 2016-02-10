require 'singleton'

module Sshez
  # Just a printing service that keeps track by all its output
  # Mainly used for testing purposes
  class PrintingManager
    include Singleton
    # An attribute reader to store printing logs
    attr_reader :output

    def initialize
      @output = ''
      @verbose = false
    end

    #
    # Adds to output then prints
    #
    def print(text)
      @output += %(#{text}\n)
      puts text
    end # print(text)

    #
    # Adds to output and prints only if verbose set to true
    #
    def verbose_print(text)
      @output += %(#{text}\n)
      puts text if @verbose
    end

    #
    # Prompts for user input
    #
    def prompt(text)
      @output += %(#{text}\n)
      print text
      STDIN.gets
    end # print(text)

    #
    # Did we print anything?
    #
    def output?
      !@output.empty?
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
      @output = ''
      @verbose = false
    end
  end # PrintingManager
end
