require "option_parser"
require "openai"

module Guppi
  class CLI
    def self.run
      OptionParser.new do |parser|
        parser.banner = "Usage: guppi [options]"

        parser.on("-h", "--help", "Show help") do
          puts parser
          exit
        end
      end

      project_file = "project.md"
      plan_file = "plan.txt"

      puts "Guppi: A semi-autonomous coding assistant.\n"

      App.run(project_file, plan_file)

      puts "Goodbye!"
    end
  end
end
