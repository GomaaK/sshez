require 'sshez/printing_manager'
require 'sshez/parser'
require 'sshez/file_manager'
require 'sshez/runner'
require 'sshez/version'
require 'optparse'
require 'ostruct'

module Sshez

  def self.version
    return Sshez::VERSION
  end
end
