require 'json'
require_relative 'array'

def process(event:, context:)
  @acordes ||= Hash.new {|h,k| h[k] = [] }
  params = JSON.parse(event["body"])
  puts "[LOGGER] #{params}"
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
      fulfillmentText: "teste",
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
  HARMONIC_FIELD.map do |harmonic_field|
    puts "[LOGGER] #{(harmonic_field[:acordes] & acordes)}"
    harmonic_field[:name] if (acordes - harmonic_field[:acordes]).empty?
  end.compact
end

HARMONIC_FIELD = [
  {
    name: "campo harmônico de dó maior",
    acordes: ["C7M", "Dm7", "Em7", "F7M", "G7", "Am7", "Bm7(b5)"]
  },
  {
    name: "campo harmônico de ré maior",
    acordes: ["D7M", "Em7", "F#m7", "G7M", "A7", "Bm7", "C#m7(b5)"]
  },
  {
    name: "campo harmônico de mi maior",
    acordes: ["E7M", "F#m7", "G#m7", "A7M", "B7", "C#m7", "D#m7(b5)"]
  },
  {
    name: "campo harmônico de fá maior",
    acordes: ["F7M", "Gm7", "Am7", "Bb7M", "C7", "Dm7", "E#m7(b5)"]
  },
  {
    name: "campo harmônico de sol maior",
    acordes: ["G7M", "Am7", "Bm7", "C7M", "D7", "Em7", "F#m7(b5)"]
  },
  {
    name: "campo harmônico de lá maior",
    acordes: ["A7M", "Bm7", "C#m7", "D7M", "E7", "F#m7", "G#m7(b5)"]
  },
  {
    name: "campo harmônico de si maior",
    acordes: ["B7M", "C#m7", "D#m7", "E7M", "F#7", "G#m7", "A#m7(b5)"]
  }
]
