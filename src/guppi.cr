require "option_parser"
require "openai"

Log.setup(:info)

require "./file_tree"
require "./agent"
require "./file_reader_agent"
require "./decision_agent"
require "./file_creator_agent"
require "./file_modifier_agent"

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

    loop do
      file_reader_agent = FileReaderAgent.new(openai_client)
      contents = file_reader_agent.what_files_contents(project_file, FileTree.new)

      File.write("context.txt", contents)

      decision_agent = DecisionAgent.new(openai_client)
      next_task = decision_agent.get_next_task(project_file, contents)

      break if next_task.nil? # Exit the loop if there are no more tasks

      case next_task.action
      when "CREATE_FILE"
        FileCreatorAgent.new(openai_client).create_file(project_file, contents, next_task)
      when "MODIFY_FILE"
        FileModifierAgent.new(openai_client).modify_file(project_file, contents, next_task)
      else
        raise "Unknown action: #{next_task.action}"
      end
    end
  end
end

Guppi.run(ARGV)
