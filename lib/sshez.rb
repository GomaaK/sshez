require 'sshez/printing_manager'
require 'sshez/parser'
require 'sshez/command'
require 'sshez/exec'
require 'sshez/runner'
require 'sshez/version'
require 'optparse'
require 'ostruct'

#
# Main gem module
#

module Sshez
	# Returns version data
  def self.version
    return Sshez::VERSION
  end
end
