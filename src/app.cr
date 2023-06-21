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
    def self.run(project_file : String, plan_file : String, default_model : String)
      openai_client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))

      loop do
        puts "\e[32mReading related files:\e[0m"
        file_reader_agent = FileReaderAgent.new(openai_client, default_model)
        contents = file_reader_agent.what_files_contents(project_file, FileTree.new)

        File.write("context.txt", contents)

        puts "\n\e[31m---\e[0m"

        puts "\e[32mThinking about the next task:\e[0m"
        decision_agent = DecisionAgent.new(openai_client, default_model)
        next_task = decision_agent.get_next_task(project_file, contents)

        break if next_task.nil? # Exit the loop if there are no more tasks

        puts "\n\e[31m---\e[0m"

        case next_task.action
        when "CREATE_FILE"
          FileCreatorAgent.new(openai_client, default_model).create_file(project_file, contents, next_task)
        when "MODIFY_FILE"
          FileModifierAgent.new(openai_client, default_model).modify_file(project_file, contents, next_task)
        when "RUN_COMMAND"
          CommandRunner.run_command(next_task)
        else
          raise "Unknown action: #{next_task.action}"
        end
      end
    end
  end
end
