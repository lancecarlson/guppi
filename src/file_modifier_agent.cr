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
        message += "Please ONLY modify the code for just this one file: '#{filepath}':\n```\n"
        message += "\n\nCurrent task:\n\n#{task.to_yaml}\n\n"
        message += "```\n"

        add_user_message(message)

        file_ext = File.extname(filepath)
        file_name = File.basename(filepath, file_ext)
        edits_filepath = File.join(File.dirname(filepath), "#{file_name}.edits#{file_ext}")

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
