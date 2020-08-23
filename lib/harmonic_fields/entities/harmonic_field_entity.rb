module HarmonicFields
  module Entities

    class HarmonicFieldEntity
      def initialize(name:, chord:, relative_to: nil)
        @name = name
        @chord = chord
        @relative_to = relative_to
      end

      attr_reader :chord, :relative_to

      def name
        if relative_to.nil?
          return @name
        end

        "#{@name} e pode ser relativo ao #{relative_to}"
      end
    end

  end
end
