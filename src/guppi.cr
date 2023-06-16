require "option_parser"
require "openai"

require "./plan_generator"
#require "./task_iterator"
#require "./file_tree_generator"
#require "./code_generator"
#require "./test_runner"
#require "./command_runner"

module Guppi
  def self.initialize_openai_client
    OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  alias OpenAIClient = OpenAI::Client

  def self.run(args)
    project_file = "project.md"
    openai_client = initialize_openai_client

    OptionParser.new do |parser|
      parser.banner = "Usage: guppi [options] [file]"
      parser.on("-f", "--file=FILE", "Specify a project file") { |file| project_file = file }
      parser.on("-h", "--help", "Show help") { puts parser; exit }
    end

    File.open("plan.txt", "w") do |file|
      plan = PlanGenerator.generate(project_file, openai_client, file)
    end

    puts "Guppi has successfully generated and executed your project!"
  end
end

Guppi.run(ARGV)