require "option_parser"

Log.setup(:info)

require "./app"
require "./cli"

module Guppi
  def self.run(args)
    CLI.run(args)
  end
end

Guppi.run(ARGV)
