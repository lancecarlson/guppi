module Guppi
  class CommandRunner
    def self.run_command(task : DecisionAgent::Task)
      raise "Invalid action: #{task.action}" unless task.action == "RUN_COMMAND"

      if command = task.command
        io = IO::Memory.new
        process = Process.new(command, output: io, error: io)
        status = process.wait
        puts "I executed the command: '#{command}' with the output:\n\n```\n#{io}\n```"
      else
        puts "No command to run."
      end
    end
  end
end
