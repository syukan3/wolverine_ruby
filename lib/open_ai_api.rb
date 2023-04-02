require 'httparty'

class OpenAIAPI
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def initialize(api_key)
    @headers = {
      "Authorization" => "Bearer #{api_key}",
      "Content-Type" => "application/json"
    }
  end

  def chat_completion(prompt)
    self.class.post(
      '/chat/completions',
      headers: @headers,
      body: {
        model: "gpt-3.5-turbo",
        # model: "gpt-4",
        messages: [
          {
            role: "user",
            content: prompt
          }
        ],
        temperature: 1.0
      }.to_json
    )
  end
end
