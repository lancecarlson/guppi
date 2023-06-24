require "./spec_helper"

def create_temporary_project_file(path)
  File.open(path, "w") do |file|
    file.print("Temporary project file for testing")
  end
end

def create_temporary_original_file(path)
  File.open(path, "w") do |file|
    file.print("Temporary original file for testing")
  end
end

describe Guppi::FileModifierAgent do
  client = OpenAI::Client.new("test_api_key")
  model = "gpt-4"
  agent = Guppi::FileModifierAgent.new(client, model)
  project_file = "project.md"
  contents = "Test file contents"

  create_temporary_project_file(project_file)
  original_file_path = "temp/original_file.cr"
  create_temporary_original_file(original_file_path)

  task = Guppi::DecisionAgent::Task.new(
    "Test file modification",
    "Modify the original file for FileModifierAgent",
    "MODIFY_FILE",
    nil,
    original_file_path
  )

  it "modifies the original file with the specified changes" do
    file_modified = agent.modify_file(project_file, contents, task)

    file_modified.should be_true
    File.exists?(original_file_path).should be_true
    File.read(original_file_path).should_not eq(contents)
  end

  it "returns false if the task's filepath is not provided" do
    task_without_filepath = task.copy_with(filepath: nil)

    file_modified = agent.modify_file(project_file, contents, task_without_filepath)

    file_modified.should be_false
  end
end
