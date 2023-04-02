# Wolverine

Wolverine is a tool that automatically fixes Ruby script errors and reruns the script until the issue is resolved. It uses OpenAI's GPT-4 or GPT-3.5 turbo API to suggest fixes for errors.

This project was developed with reference to Wolverine at the following URL: https://github.com/biobootloader/wolverine

## Prerequisites

- Ruby 2.7 or later
- [Bundler](https://bundler.io) gem
- OpenAI API key

## Setup

1. Clone or download the project.

`git clone https://github.com/syukan3/wolverine_ruby.git`

2. Navigate to the project directory.

`cd wolverine`

3. Install necessary gems.

`bundle install`

4. Save your OpenAI API key in the `config/openai_key.txt` file.

`echo "your_api_key" > config/openai_key.txt`

## Usage

Use Wolverine to execute your script with arguments.

`ruby ./bin/main.rb buggy_ruby.rb arg1 arg2`

If you want to revert the changes made by Wolverine, use the `--revert` option.

`ruby ./bin/main.rb buggy_ruby.rb --revert`


