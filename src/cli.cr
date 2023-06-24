require "option_parser"
require "openai"

module Guppi
  class CLI
    def self.run(args)
      default_model = "gpt-4-0613"

      parser = OptionParser.new do |parser|
        parser.banner = "Usage: guppi [options]"

        parser.on("-h", "--help", "Show help") do
          puts parser
          exit
        end

        parser.on("-m MODEL", "Override default OpenAI model") do |model|
          default_model = model
        end
      end

      parser.parse(args)

      project_file = "project.md"
      plan_file = "plan.json"

      puts "Guppi: A semi-autonomous coding assistant.\n"

      App.run(project_file, plan_file, default_model)

      puts "Goodbye!"
    end
  end
end
