# frozen_string_literal: true

require "core_ext/array"

require "harmonic_fields/entities/session_entity"
require "harmonic_fields/entities/harmonic_field_entity"
require "harmonic_fields/repositories/session_repository"
require "harmonic_fields/repositories/harmonic_field_repository"

module HarmonicFields
  module Services

    class HarmonicFieldFinder
      def initialize(params)
        @new_chord = HarmonicFields::ValueObjects::Chord.new(name: params[:chord])

        session_id = params[:session_id]
        @session_repository = HarmonicFields::Repositories::SessionRepository.new(session_id: session_id)

        @harmonic_field_repository = HarmonicFields::Repositories::HarmonicFieldRepository.new
      end

      def process
        chords = session_repository.chords

        chords.push(@new_chord)

        harmonic_field_found = search_chord_in_harmonic_field(chords)

        message = ""
        if harmonic_field_found.size <= 1
          if harmonic_field_found.size == 1
            message = "Show! Sua música está no #{harmonic_field_found.to_sentence}."
          else
            message = "Não conseguimos encontrar um campo harmônico com esses acordes."
          end
          session_repository.delete_chords
        else
          message = "Legal, o acorde pode estar no #{harmonic_field_found.to_sentence}. Fale-me outro acorde da mesma música."
          session_repository.update_chords(chords)
        end

        message
      end

      private

      attr_reader :session_repository, :harmonic_field_repository

      def search_chord_in_harmonic_field(chords)
        harmonic_fields = chords.map do |chord|
          harmonic_field_repository.find_by_chord(chord).map(&:name)
        end

        find_what_harmonic_field_is_present_in_all_elements(harmonic_fields)
      end

      def find_what_harmonic_field_is_present_in_all_elements(harmonic_fields)
        result = harmonic_fields.shift
        harmonic_fields.each do |harmonic_field|
          result &= harmonic_field
        end
        result
      end
    end

  end
end
