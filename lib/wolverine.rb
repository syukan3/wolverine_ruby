require 'open3'
require 'json'
require 'diffy'
require 'fileutils'
require_relative 'open_ai_api'

class Wolverine
  def initialize(api_key)
    @openai_api = OpenAIAPI.new(api_key)
  end

  def run_script(script_name, *args)
    stdout, stderr, status = Open3.capture3("ruby", script_name, *args)
    if status.success?
      return stdout, 0
    else
      return stderr, status.exitstatus
    end
  end

  def send_error_to_gpt4(file_path, args, error_message)
    file_with_lines = File.readlines(file_path).each_with_index.map { |line, i| "#{i + 1}: #{line}" }.join
    prompt = <<-PROMPT
    #{File.read("./config/prompt.txt")}
    Here is the script that needs fixing:
    #{file_with_lines}
    Here are the arguments it was provided:
    #{args}
    Here is the error message:
    #{error_message}
    Please provide your suggested changes, and remember to stick to the exact format as described above.
    PROMPT
    response = @openai_api.chat_completion(prompt)
    response["choices"][0]["message"]["content"].strip
  end

  def apply_changes(file_path, changes_json)
    original_file_lines = File.readlines(file_path)
    changes = JSON.parse(changes_json)
    operation_changes = changes.select { |change| change.key?("operation") }.sort_by { |x| -x["line"] }
    explanations = changes.select { |change| change.key?("explanation") }.map { |change| change["explanation"] }
    file_lines = original_file_lines.dup

    operation_changes.each do |change|
      operation, line, content = change.values_at("operation", "line", "content")
      case operation
      when "Replace" then file_lines[line - 1] = content + "\n"
      when "Delete" then file_lines.delete_at(line - 1)
      when "InsertAfter" then file_lines.insert(line, content + "\n")
      end
    end

    File.write(file_path, file_lines.join)
    puts "\e[34mExplanations:\e[0m", explanations.map { |explanation| "\e[34m- #{explanation}\e[0m" }, "\nChanges:"
    puts Diffy::Diff.new(original_file_lines.join, file_lines.join).to_s(:color)
  end
end
