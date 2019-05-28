require 'json'
require 'httparty'
require 'nokogiri'
require 'aws-sdk-dynamodb'

require_relative 'array'

ALLOWED_INTENTS = ["acorde", "cifra"]

def process(event:, context:)
  params = JSON.parse(event["body"])

  puts "[LOGGER] #{params}"

  intent = params["queryResult"]["intent"]["displayName"]
  send(intent, params)
end

def cifra(params)
  song = params["queryResult"]["parameters"]["song"]

  response = HTTParty.get("https://www.google.com/search?q=#{song}+cifra")

  doc = Nokogiri::HTML(response)
  link = doc.css("#search a:first-of-type").first["href"].match(/http.*/).to_s

  {
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    statusCode: 200,
    body: JSON.generate({
      followupEventInput: {
        name: "cifra-found",
        languageCode: "pt-BR",
        parameters: {
          "cifra" => link
        }
      }
    })
  }
end

def acorde(params)
  table = Aws::DynamoDB::Table.new("chords_by_sessions")
  options = {} # TODO: Add options Hash
  chords = table.query(options).items.map { |item| item["chord"] }

  new_chord = params["queryResult"]["parameters"]["acorde"]
  chords.push(new_chord)

  harmonic_field_found = search_acorde_in_harmonic_field(chords)

  event_name = ""
  if harmonic_field_found.size <= 1
    event_name = "campo-harmonico-completely-found"
    # TODO: Remove chords from the session
  else
    event_name = "campo-harmonico-found"
    # TODO: Add new chord to the session
  end

  puts "[LOGGER] #{harmonic_field_found}"
  {
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    statusCode: 200,
    body: JSON.generate({
      followupEventInput: {
        name: event_name,
        languageCode: "pt-BR",
        parameters: {
          "campo-harmonico" => harmonic_field_found.to_sentence
        }
      }
    })
  }
end

def search_acorde_in_harmonic_field(acordes)
  table = Aws::DynamoDB::Table.new("harmonic_fields")

  campos = acordes.map do |acorde|
    options = { key_condition_expression: "chord = :chord", expression_attribute_values: { ":chord" => acorde } }
    items = table.query(options).items
    items.map { |item| item["name"] }
  end

  {}.tap do |result|
    result = campos.shift
    campos.each { |campo| result &= campo }
  end
end
