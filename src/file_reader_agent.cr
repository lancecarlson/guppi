require "openai"
require "yaml"

module Guppi
  class FileReaderAgent < Agent
    def initialize(client : OpenAIClient, model : String = "gpt-4")
      super
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
      message = "Here is the project description:\n\n"
      message += File.read(project_file) + "\n\n"

      message += "Here are the current files in the project:"
      message += file_tree.to_s

      message += "List the top files that I should read to figure out what to do next. Return only valid YAML of the full filepaths. Do not include reasoning or annotations. "
      message += "Keep in mind that we have a context window of 7500 tokens.\n"
      message += "```yaml"

      message
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
