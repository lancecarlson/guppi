module Guppi
  class DecisionAgent < Agent
    def initialize(client : OpenAIClient, model : String = "gpt-4")
      super
      @completed_tasks_file = "tasks.md"
    end

    def build_prompt(project_file : String, contents : String)
      project_description = File.read(project_file)

      prompt = "Project description:\n\n"
      prompt += project_description + "\n\n"

      prompt += "Completed tasks:\n\n"
      prompt += get_completed_tasks

      prompt += "Contents of the relevant files:\n\n"
      prompt += contents

      prompt += "Given the project description, completed tasks, and the contents of the relevant files, please provide the most reasonable next task that can be implemented to achieve the goals set in the project description:\n\n"
      prompt += "Include the following fields in your YAML object: title, description, action (CREATE_FILE, MODIFY_FILE, DELETE_FILE, RUN_COMMAND), command (if action is RUN_COMMAND), filepath\n\n"

      prompt += "Next task:\n\n"
      prompt += "```yaml"

      prompt
    end

    record Task, title : String, description : String, action : String, command : String | Nil, filepath : String | Nil do
      include YAML::Serializable
    end

    def get_next_task(project_file : String, contents : String) : Task
      prompt = build_prompt(project_file, contents)
      add_user_message(prompt)

      next_task = ""
      chat do |response|
        print response
        next_task += response
      end

      task = Task.from_yaml(next_task.strip)
      write_completed_task(task) if task
      task
    end

    private def write_completed_task(task : Task)
      File.open(@completed_tasks_file, "a") do |file|
        file.puts(task.to_yaml)
      end
    end

    private def get_completed_tasks
      return "No completed tasks yet." unless File.exists?(@completed_tasks_file)

      contents = File.read(@completed_tasks_file)
      "```\n" + contents + "\n```\n"
    end
  end
end
