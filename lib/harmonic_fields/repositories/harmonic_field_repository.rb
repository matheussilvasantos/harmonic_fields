# frozen_string_literal: true

require "harmonic_fields/entities/harmonic_field_entity"

require "aws-sdk-dynamodb"

module HarmonicFields
  module Repositories

    class HarmonicFieldRepository
      def initialize
        @table = Aws::DynamoDB::Table.new(TABLE_NAME)
      end

      def find_by_chord(chord)
        options = {
          :key_condition_expression    => "chord = :chord",
          :expression_attribute_values => {
            ":chord" => chord.name
          }
        }

        table.query(options).items.map do |item|
          Entities::HarmonicFieldEntity.new(
            name: item["name"],
            chord: item["chord"],
            relative_to: item["relative_to"]
          )
        end
      end

      private

      attr_reader :table

      TABLE_NAME = "harmonic_fields"
      private_constant :TABLE_NAME
    end

  end
end
