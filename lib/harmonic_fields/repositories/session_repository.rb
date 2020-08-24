# frozen_string_literal: true

require "harmonic_fields/value_objects/chord"

require "aws-sdk-dynamodb"

module HarmonicFields
  module Repositories

    class SessionRepository
      def initialize(session_id:)
        @session_id = session_id
        @table = Aws::DynamoDB::Table.new(TABLE_NAME)
      end

      def update_chords(chords)
        options = {
          :key               => {
            "session" => session_id
          },
          :attribute_updates => {
            "chords" => {
              :value  => chords.map(&:name),
              :action => "PUT"
            }
          }
        }

        table.update_item(options)
      end

      def delete_chords
        options = {
          :key => {
            "session" => session_id
          }
        }

        table.delete_item(options)
      end

      def chords
        options = {
          :key => {
            "session" => session_id
          }
        }

        item = table.get_item(options).item
        chord_names = item&.dig("chords") || []
        chord_names.map do |chord_name|
          ValueObjects::Chord.new(name: chord_name)
        end
      end

      private

      attr_reader :session_id, :table

      TABLE_NAME = "chords_by_session"
      private_constant :TABLE_NAME
    end

  end
end
