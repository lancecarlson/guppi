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

      openai_client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
      project_file = "project.md"
      plan_file = "plan.txt"

      puts "Guppi: A semi-autonomous coding assistant.\n"

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

      puts "Goodbye!"
    end
  end
end
