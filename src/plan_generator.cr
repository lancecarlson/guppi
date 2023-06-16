require "openai"

module Guppi
  class Task
    getter description : String
      
    def initialize(@description : String)
    end
  end

  class PlanGenerator
    def self.generate(project_file : String, openai_client : OpenAIClient, output_io : IO)
      project_content = File.read(project_file)
      chat_messages = [
        {role: "user", content: "Please generate a numbered Task list from the following project description:"},
        {role: "user", content: project_content},
      ]

      openai_client.chat("gpt-3.5-turbo", chat_messages, {"stream" => true}) do |chunk|
        delta = chunk.choices.first.delta
        next unless delta.has_key?("content")
        output_chunk = delta["content"]
        print output_chunk
        output_io << output_chunk
      end
    end

    private def self.parse_task(buffer : String) : String
      task = buffer.split(". ", 2).last # Ignore the task number and period.
      task.chomp # Remove newline at the end, if present.
      task
    end

    private def self.parse_todo_list(todo_list_text : String) : Array(Task)
      tasks = [] of Task
      buffer = IO::Memory.new(todo_list_text)
      buffer.each_line do |line|
        begin
          task = parse_task(line)
          tasks << Task.new(task)
        rescue ex
          puts "[WARN] Skipped task: #{ex.message}"
        end
      end
      tasks
    end
  end
end
