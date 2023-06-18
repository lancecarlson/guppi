require "option_parser"
require "openai"

Log.setup(:info)

require "./file_tree"
require "./agent"
require "./file_reader_agent"
require "./decision_agent"
require "./file_creator_agent"
require "./file_modifier_agent"
require "./cli"

module Guppi
  def self.run
    CLI.run
  end
end

Guppi.run
