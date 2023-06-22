require "openai"

module Guppi
  class Agent
    alias OpenAIClient = OpenAI::Client

    getter :prompts, :client, :messages, :model

    def initialize(prompts : Crinja, client : OpenAIClient, model : String = "gpt-3.5-turbo")
      @prompts = prompts
      @client = client
      @messages = [] of NamedTuple(role: String, content: String)
      @model = model
    end

    def add_message(role : String, content : String)
      @messages << {role: role, content: content}
      self
    end

    def add_user_message(content : String)
      add_message("user", content)
    end

    def add_system_message(content : String)
      add_message("system", content)
    end

    def add_agent_message(content : String)
      add_message("assistant", content)
    end

    def chat(params : Hash(String, String | Bool | Float32 | Int32) = {} of String => Bool | String, &block : String -> Nil)
      params["stream"] = true

      @client.chat(@model, @messages, params) do |chunk|
        choice = chunk.choices.first
        delta = choice.delta
        if delta.has_key?("content")
          block.call(delta["content"])
        end
      end
    end

    def end_conversation
      @messages = [] of NamedTuple(role: String, content: String)
    end

    def render(template_name, context)
      template = prompts.get_template("#{template_name}.txt.j2")
      template.render(context)
    end
  end
end
