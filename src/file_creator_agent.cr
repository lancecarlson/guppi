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

        File.open(filepath, "w") do |file|
          chat do |response|
            file.print(response)
            print response
          end
        end

        return true
      end

      false
    end
  end
end
