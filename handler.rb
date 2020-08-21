# frozen_string_literal: true

require "json"

require_relative "lib/init"

def process(event:, context:)
  params = JSON.parse(event["body"])
  intent = params["queryResult"]["intent"]["displayName"]

  puts "[LOGGER] Intent: #{intent}"
  puts "[LOGGER] Params: #{params}"

  response = HarmonicFields.process_intent(intent: intent, params: params)

  {
    :headers    => {
      "Access-Control-Allow-Origin" => "*"
    },
    :statusCode => 200,
    :body       => JSON.generate(response)
  }
end
