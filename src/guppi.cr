require "option_parser"

Log.setup(:info)

require "./app"
require "./cli"

module Guppi
  def self.run
    CLI.run
  end
end

Guppi.run
