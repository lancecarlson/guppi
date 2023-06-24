module Guppi
  class CommandRunner
    def self.run_command(step : Step)
      raise "Invalid action: #{step.action}" unless step.action == "RUN_COMMAND"

      if command = step.command
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
