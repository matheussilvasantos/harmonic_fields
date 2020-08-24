# frozen_string_literal: true

require "json"

require_relative "lib/init"

require "harmonic_fields/services/harmonic_field_finder"
require "harmonic_fields/services/cipher_finder"

def process(event:, context:)
  raw_params = JSON.parse(event["body"])
  intent = raw_params.dig("queryResult", "intent", "displayName")

  service        = Application::SERVICES_BY_INTENT[intent]
  service_params = Application::INTENT_BUILDERS[intent].call(raw_params)
  message = service.new(service_params).process

  response = { :fulfillmentText => message }

  {
    :headers    => {
      "Access-Control-Allow-Origin" => "*"
    },
    :statusCode => 200,
    :body       => JSON.generate(response)
  }
end

class Application
  INTENT_BUILDERS = {
    "acorde" => proc do |params|
      {
        :chord      => params.dig("queryResult", "parameters", "acorde"),
        :session_id => params["session"]
      }
    end,
    "cifra"  => proc do |params|
      {
        :song  => params.dig("queryResult", "parameters", "song")
      }
    end
  }

  SERVICES_BY_INTENT = {
    "acorde" => HarmonicFields::Services::HarmonicFieldFinder,
    "cifra"  => HarmonicFields::Services::CipherFinder,
  }
end
