require 'json'
require_relative 'array'
require 'httparty'
require 'nokogiri'

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
  @acordes ||= Hash.new {|h,k| h[k] = [] }
  session = params["session"]
  acorde = params["queryResult"]["parameters"]["acorde"]
  @acordes[session].push(acorde)
  harmonic_field_found = search_acorde_in_harmonic_field(@acordes[session])
  event_name = "campo-harmonico-found"
  if harmonic_field_found.size <= 1
    event_name = "campo-harmonico-completely-found"
    @acordes[session] = []
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
  options = { key_condition_expression: "chord = :chord", expression_attribute_values: { ":chord" => acorde } }
  table.query(options).items
  HARMONIC_FIELD.map do |harmonic_field|
    puts "[LOGGER] #{(harmonic_field[:acordes] & acordes)}"
    harmonic_field[:name] if (acordes - harmonic_field[:acordes]).empty?
  end.compact
end
