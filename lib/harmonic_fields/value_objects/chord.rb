# frozen_string_literal: true

module HarmonicFields
  module ValueObjects

    class Chord
      def initialize(name:)
        @name = name.freeze
      end

      attr_reader :name
    end

  end
end
