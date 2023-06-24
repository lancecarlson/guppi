require "yaml"

module Guppi
  class DecisionAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String = "gpt-4")
      super(prompts, client, model)
      @completed_tasks_file = "tasks.md"
    end

    def build_prompt(project_file : String, contents : String)
      project_description = File.read(project_file)
      completed_tasks = get_completed_tasks

      return render("action", {
        "project_description" => project_description,
        "completed_tasks"     => completed_tasks,
        "contents"            => contents,
      })
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
