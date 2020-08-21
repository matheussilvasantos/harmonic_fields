# frozen_string_literal: true

require "core_ext/array"

require "harmonic_fields/entities/session_entity"
require "harmonic_fields/repositories/session_repository"

require "aws-sdk-dynamodb"

class Chord
  def initialize(params)
    @new_chord = params["queryResult"]["parameters"]["acorde"]
    @session_entity = HarmonicFields::Entities::SessionEntity.new(id: params["session"])
    @session_repository = HarmonicFields::Repositories::SessionRepository.new(session: session_entity)
  end

  def process
    chords = session_repository.chords

    chords.push(@new_chord)

    harmonic_field_found = search_acorde_in_harmonic_field(chords)

    fulfillment_text = ""
    if harmonic_field_found.size <= 1
      if harmonic_field_found.size == 1
        fulfillment_text = "Show! Sua música está no #{harmonic_field_found.to_sentence}."
      else
        fulfillment_text = "Não conseguimos encontrar um campo harmônico com esses acordes."
      end
      session_repository.delete_chords
    else
      fulfillment_text = "Legal, o acorde pode estar no #{harmonic_field_found.to_sentence}. Fale-me outro acorde da mesma música."
      session_repository.update_chords(chords)
    end

    puts "[LOGGER] #{harmonic_field_found}"

    { fulfillmentText: fulfillment_text }
  end

  private

  attr_reader :session_entity, :session_repository

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
end
