require "openai"

module Guppi
  class Task
    getter description : String
      
    def initialize(@description : String)
    end
  end

  class PlanGenerator
    getter agent : Agent

    def initialize(openai_client : Agent::OpenAIClient)
      @agent = Agent.new(openai_client)
    end

    def generate(project_file : String, output_io : IO)
      project_content = File.read(project_file)
      agent.add_user_message("Please generate a numbered Task list from the following project description:")
      agent.add_user_message(project_content)

      agent.chat do |chunk|
        print chunk 
        output_io << chunk
      end
      agent.end_conversation
    end
  end
end
