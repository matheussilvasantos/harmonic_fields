# frozen_string_literal: true

require "intents/chord"
require "intents/cipher"

module HarmonicFields
  ALLOWED_INTENTS = {
    "acorde" => Chord,
    "cifra"  => Cipher
  }

  def self.process_intent(intent:, params:)
    intent = ALLOWED_INTENTS[intent]

    response = {}
    unless intent.nil?
      response = intent.new(params).process
    end

    response
  end
end
