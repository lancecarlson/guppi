require "option_parser"
require "openai"

require "./agent"
require "./plan_generator"
require "./tasks"
#require "./file_tree_generator"
#require "./code_generator"
#require "./test_runner"
#require "./command_runner"

module Guppi
  def self.initialize_openai_client
    OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  alias OpenAIClient = OpenAI::Client

  def self.run(args)
    project_file = "project.md"
    plan_file = "plan.txt"
    openai_client = initialize_openai_client

    OptionParser.new do |parser|
      parser.banner = "Usage: guppi [options] [file]"
      parser.on("-f", "--file=FILE", "Specify a project file") { |file| project_file = file }
      parser.on("-h", "--help", "Show help") { puts parser; exit }
    end

    generate_plan(project_file, plan_file, openai_client)

    tasks = Tasks.from_file(plan_file)
    tasks.process_tasks(openai_client)
  end

  def self.generate_plan(project_file, plan_file, openai_client)
    if File.exists?(plan_file)
      puts "Plan exists:"
      puts File.read(plan_file)
      puts "Continue or regenerate? (c/r)"
      loop do
        user_input = gets
        if user_input
          user_input = user_input.chomp.downcase
          if user_input == "c"
            break
          elsif user_input == "r"
            File.delete(plan_file)
            generate_plan(project_file, plan_file, openai_client)
          end
        end
      end

      return
    end

    feedback = nil

    loop do
      File.open(plan_file, "w") do |file|
        plan = PlanGenerator.new(openai_client).generate(project_file, file)
      end

      puts "\n"
      puts "Does this plan look good? (y/n)"

      user_input = gets
      if user_input
        user_input = user_input.chomp.downcase
        if user_input == "y"
          break
        else
          puts "Enter feedback for the generator:"
          feedback = gets
          if feedback
            feedback = feedback.chomp
            # Use the feedback value as desired, possibly as input to your generator
          end
        end
      end
    end
  end
end

Guppi.run(ARGV)