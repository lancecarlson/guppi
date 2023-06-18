require "openai"

module Guppi
  class FileModifierAgent < Agent
    def initialize(client : OpenAIClient, model : String = "gpt-3.5-turbo")
      super
    end

    def modify_file(project_file : String, contents : String, task : DecisionAgent::Task, persona : String? = nil) : Bool
      if persona
        add_system_message(persona)
      end

      project_description = File.read(project_file)

      if filepath = task.filepath
        file_contents = File.read(filepath)

        message = "Project description:\n\n#{project_description}"
        message += "Related file contents:\n\n#{contents}"
        message += "Original file contents:\n#{file_contents}\n\n"
        message += "Please modify the code in this file: '#{filepath}':\n```\n"
        message += "\n\nCurrent task:\n\n#{task.to_yaml}\n\n"

        add_user_message(message)

        edits_filepath = filepath + ".edits"

        File.open(edits_filepath, "w") do |file|
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
