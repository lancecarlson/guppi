require "openai"

module Guppi
  class Task
    getter description : String
      
    def initialize(@description : String)
    end
  end

  class TaskAgent
    getter agent : Agent

    def initialize(openai_client : Agent::OpenAIClient)
      @agent = Agent.new(openai_client)
    end

    def self.from_file(plan_file : String) : Array(Task)
      tasks = [] of Task
      File.open(plan_file, "r") do |file|
        file.each_line do |line|
          next if line.match(/^\D/)
          task = parse_task(line)
          next if task.empty?
          tasks << Task.new(task)
        end
      end
      tasks
    end

    def process_tasks(tasks : Array(Task))
      tasks.each do |task|
        relevant_files = get_relevant_files(task)
        puts "\n"
        puts "Relevant files:"
        relevant_files.each { |file| puts "  #{file}" }
      end
    end

    private def get_relevant_files(task : Task) : Array(String)
      message = "Given the following task, what are the relevant files I need to complete it?\n"
      message += "Task: #{task.description}"

      puts message

      agent.add_user_message(message)

      response_text = ""
      agent.chat do |chunk|
        print chunk
        response_text += chunk
      end
      agent.end_conversation

      response_text.split("\n").select { |file| !file.empty? }
    end

    private def self.parse_task(buffer : String) : String
      task = buffer.split(". ", 2).last # Ignore the task number and period.
      task.chomp # Remove newline at the end, if present.
      task
    end
  end
end