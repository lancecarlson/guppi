require "openai"

module Guppi
  class FileChanges
    include JSON::Serializable

    @[JSON::Field(description: "The diff formatted changes for the entire file compatible with the patch linux command.")]
    getter diff : String
  end

  class FileModifierAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String = "gpt-4")
      super
    end

    def modify_file(project_file : String, contents : String, step : Step) : Bool
      project_description = File.read(project_file)

      if filepath = step.filepath
        # Check if the file exists, create it if not
        File.write(filepath, "") unless File.exists?(filepath)
        file_contents = File.read(filepath)

        message = render("file_modifier_agent", {
          "project_description" => project_description,
          "contents"            => contents,
          "file_contents"       => file_contents,
          "step"                => step.to_json,
        })

        add_user_message(message)

        get_patch = OpenAI.def_function("get_patch", "Get the changes to the file that need to be made in order to complete this step. Output should be in the patch format.", FileChanges)

        output = ""
        chat({"functions" => [get_patch]}) do |response|
          print response
          output += response
        end

        changes = FileChanges.from_json(output)

        file_ext = File.extname(filepath)
        file_name = File.basename(filepath, file_ext)
        diff_filepath = File.join(File.dirname(filepath), "#{file_name}#{file_ext}.diff")
        File.write(diff_filepath, changes.diff)

        if prompt_user_to_apply_changes(diff_filepath, filepath)
          apply_diff(diff_filepath, filepath)
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

    private def apply_diff(diff_filepath, filepath)
      puts "Applying changes from #{diff_filepath} to #{filepath}\n"
      system("patch #{filepath} #{diff_filepath}")
    end
  end
end
