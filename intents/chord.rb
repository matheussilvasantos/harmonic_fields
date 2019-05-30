# frozen_string_literal: true

require_relative "../lib/array"

require "aws-sdk-dynamodb"

class Chord
  def initialize(params)
    @new_chord = params["queryResult"]["parameters"]["acorde"]
    @session = params["session"]
  end

  def process
    chords = get_chords_from_session || []

    chords.push(@new_chord)

    harmonic_field_found = search_acorde_in_harmonic_field(chords)

    event_name = ""
    if harmonic_field_found.size <= 1
      event_name = "campo-harmonico-completely-found"
      delete_chords_from_session
    else
      event_name = "campo-harmonico-found"
      update_session_chords(chords)
    end

    puts "[LOGGER] #{harmonic_field_found}"
    {
      followupEventInput: {
        name: event_name,
        languageCode: "pt-BR",
        parameters: {
          "campo-harmonico" => harmonic_field_found.to_sentence
        }
      }
    }
  end

  private

  def get_chords_from_session
    table = Aws::DynamoDB::Table.new("chords_by_session")
    options = { key: { "session" => @session } }
    if item = table.get_item(options).item
      item["chords"]
    end
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

  def delete_chords_from_session
    table = Aws::DynamoDB::Table.new("chords_by_session")
    options = { key: { "session" => @session } }
    table.delete_item(options)
  end

  def update_session_chords(chords)
    table = Aws::DynamoDB::Table.new("chords_by_session")
    options = { key: { "session" => @session }, attribute_updates: { "chords" => { value: chords, action: "PUT" } } }
    table.update_item(options)
  end
end
