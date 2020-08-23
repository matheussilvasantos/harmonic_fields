# frozen_string_literal: true

require "core_ext/array"

require "harmonic_fields/entities/session_entity"
require "harmonic_fields/entities/harmonic_field_entity"
require "harmonic_fields/repositories/session_repository"
require "harmonic_fields/repositories/harmonic_field_repository"

class Chord
  def initialize(params)
    @new_chord = params["queryResult"]["parameters"]["acorde"]

    @session_entity = HarmonicFields::Entities::SessionEntity.new(id: params["session"])
    @session_repository = HarmonicFields::Repositories::SessionRepository.new(session: session_entity)

    @harmonic_field_repository = HarmonicFields::Repositories::HarmonicFieldRepository.new
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

  attr_reader :session_entity, :session_repository, :harmonic_field_repository

  def search_acorde_in_harmonic_field(chords)
    campos = chords.map do |chord|
      harmonic_field_repository.find_by_chord(chord).map(&:name)
    end

    result = campos.shift
    campos.each { |campo| result &= campo }
    result
  end
end
