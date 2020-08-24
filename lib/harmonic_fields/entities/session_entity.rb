# frozen_string_literal: true

module HarmonicFields
  module Entities

    class SessionEntity
      def initialize(id:)
        @id = id
      end

      attr_reader :id
    end

  end
end
