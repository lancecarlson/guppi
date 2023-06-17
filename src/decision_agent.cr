module Guppi
  class DecisionAgent < Agent
    def initialize(client : OpenAIClient, model : String = "gpt-4")
      super
    end

    def build_prompt(contents : String, project_file : String)
      project_description = File.read(project_file)

      prompt = "Project description:\n\n"
      prompt += project_description + "\n\n"

      prompt += "Contents of the relevant files:\n\n"
      prompt += contents

      prompt += "Given the project description and the contents of the relevant files, please provide the most reasonable next task that can be implemented to achieve the goals set in the project description:\n\n"
      prompt += "Include the following fields in your YAML object: title, description, action (CREATE_FILE, MODIFY_FILE, DELETE_FILE, RUN_COMMAND), command (if action is RUN_COMMAND)\n\n"

      prompt += "Next task:\n\n"
      prompt += "```yaml"

      prompt
    end

    record Task, title : String, description : String, action : String, command : String do
      include YAML::Serializable
    end

    def get_next_task(contents : String, project_file : String) : Task
      prompt = build_prompt(contents, project_file)
      add_user_message(prompt)

      next_task = ""
      chat do |response|
        print response
        next_task += response
      end

      Task.from_yaml(next_task.strip)
    end
  end
end
