# frozen_string_literal: true

require_relative "intents/chord"
require_relative "intents/cipher"

require "json"

ALLOWED_INTENTS = {
  "acorde" => Chord,
  "cifra" => Cipher
}

def process(event:, context:)
  params = JSON.parse(event["body"])

  puts "[LOGGER] #{params}"

  intent = params["queryResult"]["intent"]["displayName"]

  response = ALLOWED_INTENTS[intent].new(params).process

  {
    headers: { "Access-Control-Allow-Origin": "*" },
    statusCode: 200,
    body: JSON.generate(response)
  }
end
