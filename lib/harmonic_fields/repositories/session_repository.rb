# frozen_string_literal: true

module HarmonicFields
  module Repositories

    class SessionRepository
      def initialize(session:)
        @session = session
        @table = Aws::DynamoDB::Table.new(TABLE_NAME)
      end

      def update_chords(chords)
        options = {
          :key               => {
            "session" => session.id
          },
          :attribute_updates => {
            "chords" => {
              :value  => chords,
              :action => "PUT"
            }
          }
        }

        table.update_item(options)
      end

      def delete_chords
        options = {
          :key => {
            "session" => session.id
          }
        }

        table.delete_item(options)
      end

      def chords
        options = {
          :key => {
            "session" => session.id
          }
        }

        item = table.get_item(options).item
        item&.dig("chords") || []
      end

      private

      attr_reader :session, :table

      TABLE_NAME = "chords_by_session"
      private_constant :TABLE_NAME
    end

  end
end
