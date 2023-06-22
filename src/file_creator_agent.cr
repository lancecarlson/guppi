require "openai"
require "crinja"

module Guppi
  class FileCreatorAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String = "gpt-4")
      super(prompts, client, model)
    end

    def create_file(project_file : String, contents : String, task : DecisionAgent::Task, persona : String? = nil) : Bool
      if persona
        add_system_message(persona)
      end

      project_description = File.read(project_file)

      if filepath = task.filepath
        context = {
          "project_description" => project_description,
          "contents"            => contents,
          "task"                => task.to_yaml,
        }
        message = render("file_creator_gent", context)

        add_user_message(message)

        File.open(filepath, "w") do |file|
          chat do |response|
            file.print(response)
            print response
          end
        end

        # check if file starts with triple backticks and remove them if it does
        File.open(filepath, "r+") do |file|
          content = file.gets_to_end
          if content.starts_with?("```")
            content = content.lines[1..-1].join("\n") # Remove the first line
          end

          file.rewind
          file.print(content)
          file.truncate(content.size)
        end

        # check if file ends with triple backticks and remove them if it does
        File.open(filepath, "r+") do |file|
          if file.size >= 3
            file.seek(-3, IO::Seek::End)
            buffer = Bytes.new(3)
            file.read(buffer)
            if String.new(buffer) == "```"
              file.seek(-3, IO::Seek::End)
              file.truncate(file.size - 3)
            end
          end
        end

        return true
      end

      false
    end
  end
end
