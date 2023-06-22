require "openai"
require "yaml"
require "crinja"

module Guppi
  class FileReaderAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String = "gpt-4")
      super(prompts, client, model)
    end

    def what_files(project_file : String, file_tree : FileTree)
      message = prepare_message(project_file, file_tree)

      add_user_message(message)

      output = ""
      chat do |response|
        print response
        output += response
      end

      Array(String).from_yaml(output)
    end

    def what_files_contents(project_file : String, file_tree : FileTree)
      file_paths = what_files(project_file, file_tree)
      read_files(file_paths)
    end

    private def prepare_message(project_file : String, file_tree : FileTree)
      project_description = File.read(project_file)

      return render("file_reader_agent", {
        "project_description" => project_description,
        "file_tree"           => file_tree.to_s,
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
