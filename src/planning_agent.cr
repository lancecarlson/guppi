require "openai"

module Guppi
  enum Action
    CREATE_FILE
    MODIFY_FILE
    DELETE_FILE
    RUN_COMMAND
  end

  class Step
    include JSON::Serializable

    @[JSON::Field(description: "Step description")]
    getter step : String

    @[JSON::Field(description: "Step number")]
    getter number : Int32

    @[JSON::Field(description: "Thought can reason about the current situation")]
    getter thought : String

    @[JSON::Field(description: "Action is the next step to take")]
    getter action : Action

    @[JSON::Field(description: "Observation is the result of the action")]
    getter observation : String

    @[JSON::Field(description: "The filepath of the file that needs to be created, modified, or deleted. Nil if the action is RUN_COMMAND")]
    getter filepath : String?
  end

  record Steps, steps : Array(Step) do
    include JSON::Serializable
  end

  class PlanningAgent < Agent
    def initialize(prompts : Crinja, client : OpenAIClient, model : String)
      model = "gpt-3.5-turbo-0613"
      super(prompts, client, model)
    end

    def plan(project_file : String, relevant_files : String)
      message = prepare_message(project_file, relevant_files)

      add_user_message(message)

      plan = OpenAI.def_function("plan", "What steps do we need to take to fulfill this instruction?", Steps)

      output = ""
      params = {
        "temperature" => 0,
        "functions"   => [plan],
      }
      chat(params) do |response|
        print response
        output += response
      end

      Steps.from_json(output)
    end

    private def prepare_message(project_file : String, relevant_files : String)
      project_description = File.read(project_file)

      return render("planning", {
        "project_description" => project_description,
        "relevant_files"      => relevant_files,
      })
    end
  end
end
