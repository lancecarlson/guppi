require "openai"

module Guppi
  class FileCreatorAgent < Agent
    def initialize(client : OpenAIClient, model : String = "gpt-4")
      super
    end

    def create_file(project_file : String, contents : String, task : DecisionAgent::Task, persona : String? = nil) : Bool
      if persona
        add_system_message(persona)
      end

      project_description = File.read(project_file)
      if filepath = task.filepath
        message = "Project description:\n\n#{project_description}"
        message += "Related file contents:\n\n#{contents}"
        message += "\n\nCurrent task:\n\n#{task.to_yaml}\n\n"
        message += "Please write the code for this file: '#{filepath}':\n```\n"

        add_user_message(message)

        file_result = false

        File.open(filepath, "w") do |file|
          chat do |response|
            begin
              file.print(response)
              print response
              file_result = true
            rescue e
              Log.warn { "Failed to write to file '#{filepath}': #{e.message}" }
              file_result = false
            end
          end
        end

        file_result
      else
        DecisionAgent.new(client).get_next_task(project_file, contents)
        false
      end
    end
  end
end
