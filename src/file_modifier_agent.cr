require "openai"

module Guppi
  class FileModifierAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String = "gpt-4")
      super
    end

    def modify_file(project_file : String, contents : String, task : DecisionAgent::Task, persona : String? = nil) : Bool
      if persona
        add_system_message(persona)
      end

      project_description = File.read(project_file)

      if filepath = task.filepath
        # Check if the file exists, create it if not
        File.write(filepath, "") unless File.exists?(filepath)
        file_contents = File.read(filepath)

        message = render("file_modifier_agent", {
          "project_description" => project_description,
          "contents"            => contents,
          "file_contents"       => file_contents,
          "task"                => task,
        })

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

        if prompt_user_to_apply_changes(edits_filepath, filepath)
          replace_contents_from_edits_file(filepath, edits_filepath)
        end

        return true
      end

      false
    end

    private def prompt_user_to_apply_changes(edits_filepath, filepath)
      puts "Do you want to apply changes from edits file to original file?(y/n)\n"
      response = gets

      return false unless response == "y"

      true
    end

    private def replace_contents_from_edits_file(filepath, edits_filepath)
      File.open(filepath, "w") do |file|
        file.print(File.read(edits_filepath))
      end

      File.delete(edits_filepath)

      puts "Changes from edits file has been applied to the original file."
    end
  end
end
