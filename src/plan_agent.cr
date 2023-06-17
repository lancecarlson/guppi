module Guppi
  class PlanAgent < Agent
    def initialize(openai_client : OpenAIClient)
      super(openai_client)
    end

    def interact(project_file : String, plan_file : String)
      loop do
        if File.exists?(plan_file)
          puts "Plan exists:"
          puts File.read(plan_file)
          puts "Continue or regenerate? (c/r)"
        else
          File.open(plan_file, "w") do |file|
            generate(project_file, file)
          end

          puts "\n"
          puts "Does this plan look good? (y/n)"
        end

        user_input = gets
        if user_input
          user_input = user_input.chomp.downcase
          if user_input == "c"
            break
          elsif user_input == "r"
            puts "Enter feedback for the generator:"
            feedback = gets
            if feedback
              feedback = feedback.chomp
              previous_plan = File.read(plan_file) if File.exists?(plan_file)
              feedback += "\nPrevious plan:\n#{previous_plan}"
              regenerate(project_file, plan_file, feedback) # Use feedback to regenerate
            end
          end
        end
      end
    end

    private def generate(project_file : String, output_io : IO, feedback : String = "")
      project_content = File.read(project_file)
      add_user_message("Please generate a numbered Task list from the following project description:")
      add_user_message(project_content)
      add_user_message(feedback) unless feedback.empty?

      chat do |chunk|
        print chunk 
        output_io << chunk
      end
      end_conversation
    end

    private def regenerate(project_file : String, plan_file : String, feedback : String)
      File.delete(plan_file) if File.exists?(plan_file)  # remove the previous plan file
      File.open(plan_file, "w") do |file|
        generate(project_file, file, feedback)
      end
    end
  end
end
