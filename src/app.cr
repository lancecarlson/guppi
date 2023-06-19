require "openai"

require "./file_tree"
require "./agent"
require "./command_runner"
require "./file_reader_agent"
require "./decision_agent"
require "./file_creator_agent"
require "./file_modifier_agent"

module Guppi
  class App
    def self.run(project_file : String, plan_file : String)
      openai_client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

      loop do
        file_reader_agent = FileReaderAgent.new(openai_client)
        contents = file_reader_agent.what_files_contents(project_file, FileTree.new)

        File.write("context.txt", contents)

        puts "\n---"

        decision_agent = DecisionAgent.new(openai_client)
        next_task = decision_agent.get_next_task(project_file, contents)

        break if next_task.nil? # Exit the loop if there are no more tasks

        case next_task.action
        when "CREATE_FILE"
          FileCreatorAgent.new(openai_client).create_file(project_file, contents, next_task)
        when "MODIFY_FILE"
          FileModifierAgent.new(openai_client).modify_file(project_file, contents, next_task)
        when "RUN_COMMAND"
          CommandRunner.run_command(next_task)
        else
          raise "Unknown action: #{next_task.action}"
        end
      end
    end
  end
end
