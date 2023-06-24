require "openai"
require "crinja"

require "./file_tree"
require "./agent"
require "./command_runner"
require "./file_reader_agent"
require "./planning_agent"
require "./decision_agent"
require "./file_creator_agent"
require "./file_modifier_agent"

module Guppi
  class App
    def self.run(project_file : String, plan_file : String, default_model : String)
      openai_client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
      prompts = Crinja.new
      prompts.loader = Crinja::Loader::FileSystemLoader.new("prompts/")

      puts "\e[32mReading related files:\e[0m"
      file_reader_agent = FileReaderAgent.new(prompts, openai_client, default_model)
      contents = file_reader_agent.what_files_contents(project_file, FileTree.new)

      File.write("context.txt", contents)

      puts "\n\e[31m---\e[0m"

      puts "\e[32mCompiling plan:\e[0m"
      plan_agent = PlanningAgent.new(prompts, openai_client, default_model)
      plan = plan_agent.plan(project_file, contents)

      File.write(plan_file, plan.to_json)

      plan.steps.each do |step|
        puts "\n\e[32mNext step:\e[0m"
        puts step.to_pretty_json

        puts "\e[32mReading related files:\e[0m"

        file_reader_agent = FileReaderAgent.new(prompts, openai_client, default_model)
        contents = file_reader_agent.what_files_contents(project_file, FileTree.new, step)

        puts "\n\e[31m---\e[0m"

        case step.action
        when Action::CREATE_FILE
          FileCreatorAgent.new(prompts, openai_client, default_model).create_file(project_file, contents, step)
        when Action::MODIFY_FILE
          FileModifierAgent.new(prompts, openai_client, default_model).modify_file(project_file, contents, step)
        when Action::RUN_COMMAND
          CommandRunner.run_command(step)
        else
          raise "Unknown action: #{step.action}"
        end
      end
    end
  end
end
