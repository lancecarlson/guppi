require "option_parser"
require "openai"

require "./file_tree"
require "./agent"
require "./file_reader_agent"
require "./plan_agent"
require "./task_agent"

# require "./file_tree_generator"
# require "./code_generator"
# require "./test_runner"
# require "./command_runner"

module Guppi
  def self.initialize_openai_client
    OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  alias OpenAIClient = OpenAI::Client

  def self.run(args)
    project_file = "project.md"
    plan_file = "plan.txt"
    openai_client = initialize_openai_client

    OptionParser.new do |parser|
      parser.banner = "Usage: guppi [options] [file]"
      parser.on("-f", "--file=FILE", "Specify a project file") { |file| project_file = file }
      parser.on("-h", "--help", "Show help") { puts parser; exit }
    end

    file_reader_agent = FileReaderAgent.new(openai_client)
    contents = file_reader_agent.what_files_contents(project_file, FileTree.new)
    pp contents

    # plan_agent = PlanAgent.new(openai_client)
    # plan_agent.interact(project_file, plan_file)

    # tasks = TaskAgent.from_file(plan_file)
    # task_agent = TaskAgent.new(openai_client)
    # task_agent.process_tasks(tasks)
  end
end

Guppi.run(ARGV)
