#!/usr/bin/env ruby
require_relative '../lib/wolverine'

def main
  if ARGV.length < 2
    puts "Usage: wolverine.rb <script_name> <arg1> <arg2> ... [--revert]"
    exit(1)
  end

  script_name, args = ARGV[0], ARGV[1..-1]
  args.include?("--revert") ? (FileUtils.cp("#{script_name}.bak", script_name); puts "Reverted changes to #{script_name}"; exit(0)) : FileUtils.cp(script_name, "#{script_name}.bak")
  api_key = File.read("config/openai_key.txt").strip
  wolverine = Wolverine.new(api_key)

  loop do
    output, returncode = wolverine.run_script(script_name, *args)

    if returncode == 0
      puts "\e[34mScript ran successfully.\e[0m"
      puts "Output: #{output}"
      break
    else
      puts "\e[34mScript crashed. Trying to fix...\e[0m"
      puts "Output: #{output}"

      json_response = wolverine.send_error_to_gpt4(script_name, args, output)
      wolverine.apply_changes(script_name, json_response)
      puts "\e[34mChanges applied. Rerunning...\e[0m"
    end
  end
end

main
