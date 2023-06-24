require "openai"
require "crinja"

module Guppi
  record Files, files : Array(String) do
    include JSON::Serializable
  end

  class FileReaderAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String)
      model = "gpt-3.5-turbo-16k-0613"
      super(prompts, client, model)
    end

    def what_files(project_file : String, file_tree : FileTree, current_step : Step | Nil)
      message = prepare_message(project_file, file_tree, current_step)

      add_user_message(message)

      get_files = OpenAI.def_function("get_files", "List the top files that I should read to figure out what to do next.", Files)

      output = ""
      chat({"functions" => [get_files]}) do |response|
        print response
        output += response
      end

      Files.from_json(output)
    end

    def what_files_contents(project_file : String, file_tree : FileTree)
      file_paths = what_files(project_file, file_tree, nil)
      read_files(file_paths.files)
    end

    def what_files_contents(project_file : String, file_tree : FileTree, current_step : Step | Nil)
      file_paths = what_files(project_file, file_tree, current_step)
      read_files(file_paths.files)
    end

    private def prepare_message(project_file : String, file_tree : FileTree, current_step : Step | Nil)
      project_description = File.read(project_file)

      return render("relevant_files", {
        "project_description" => project_description,
        "file_tree"           => file_tree.to_s,
        "current_step"        => current_step.to_json,
      })
    end

    private def read_files(file_paths : Array(String)) : String
      file_contents = ""

      file_paths.each do |file_path|
        if File.exists?(file_path)
          file_contents += "\n## #{file_path}\n"
          file_contents += "```\n"
          file_contents += File.read(file_path)
          file_contents += "\n```\n"
        end
      end

      file_contents
    end
  end
end
