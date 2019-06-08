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

    fulfillment_text = ""
    if harmonic_field_found.size <= 1
      if harmonic_field_found.size == 1
        fulfillment_text = "Show! Sua música está no #{harmonic_field_found.to_sentence}."
      else
        fulfillment_text = "Não conseguimos encontrar um campo harmônico com esses acordes."
      end
      delete_chords_from_session
    else
      fulfillment_text = "Legal, o acorde pode estar no #{harmonic_field_found.to_sentence}. Fale-me outro acorde da mesma música."
      update_session_chords(chords)
    end

    puts "[LOGGER] #{harmonic_field_found}"

    { fulfillmentText: fulfillment_text }
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
      items.map { |item| get_harmonic_field_name(item) }
    end

    result = campos.shift
    campos.each { |campo| result &= campo }
    result
  end

  def get_harmonic_field_name(item)
    return item["name"] unless item["relative_to"]
    "#{item["name"]} e pode ser relativo ao #{item["relative_to"]}"
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
