require "openai"

module Guppi
  class FileModifierAgent < Agent
    def initialize(client : OpenAIClient, model : String = "gpt-3.5-turbo")
      super
    end

    def modify_file(filepath : String, modification : String)
      file_contents = File.read(filepath)
      modified_contents = ""

      add_system_message("Original file contents:\n#{file_contents}")
      add_user_message("Apply the following modification:\n#{modification}")

      chat do |response|
        print response
        modified_contents += response
      end

      File.write(filepath, modified_contents)

      puts "File '#{filepath}' has been modified."
    end
  end
end
