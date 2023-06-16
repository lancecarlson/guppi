require "openai"

module Guppi
  class Tasks
    property tasks : Array(Task)

    def initialize(@tasks = [] of Task)
    end

    def self.from_file(plan_file : String) : Tasks
      tasks = [] of Task
      File.open(plan_file, "r") do |file|
        file.each_line do |line|
          next if line.match(/^\D/)
          task = parse_task(line)
          next if task.empty?
          tasks << Task.new(task)
        end
      end
      Tasks.new(tasks)
    end

    def process_tasks(openai_client : OpenAIClient)
      @tasks.each do |task|
        relevant_files = self.get_relevant_files(task, openai_client)
        puts "\n"
        puts "Relevant files:"
        relevant_files.each { |file| puts "  #{file}" }
      end
    end

    private def get_relevant_files(task : Task, openai_client : OpenAIClient) : Array(String)
      message = "Given the following task, what are the relevant files I need to complete it?\n"
      message += "Task: #{task.description}"

      puts message

      chat_messages = [{role: "user", content: message}]

      response_text = ""
      openai_client.chat("gpt-3.5-turbo", chat_messages, {"stream" => true}) do |chunk|
        delta = chunk.choices.first.delta
        next unless delta.has_key?("content")
        print delta["content"]
        response_text += delta["content"]
      end

      response_text.split("\n").select { |file| !file.empty? }
    end

    private def self.parse_task(buffer : String) : String
      task = buffer.split(". ", 2).last # Ignore the task number and period.
      task.chomp # Remove newline at the end, if present.
      task
    end
  end
end