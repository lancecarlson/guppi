require "./spec_helper"

def create_temporary_project_file(path)
  File.open(path, "w") do |file|
    file.print("Temporary project file for testing")
  end
end

describe Guppi::FileCreatorAgent do
  client = OpenAI::Client.new("test_api_key")
  model = "gpt-4"
  agent = Guppi::FileCreatorAgent.new(client, model)
  project_file = "project.md"
  contents = "Test file contents"

  create_temporary_project_file(project_file)

  task = Guppi::DecisionAgent::Task.new(
    "Test file creation",
    "Create a test file for FileCreatorAgent",
    "CREATE_FILE",
    nil,
    "temp/test_file.cr"
  )

  it "creates a new file with the specified name and contents" do
    file_created = agent.create_file(project_file, contents, task)

    file_created.should be_true
    File.exists?("temp/test_file.cr").should be_true
    File.read("temp/test_file.cr").should eq(contents)
  end

  it "returns false if the task's filepath is not provided" do
    task_without_filepath = task.copy_with(filepath: nil)

    file_created = agent.create_file(project_file, contents, task_without_filepath)

    file_created.should be_false
  end
end
