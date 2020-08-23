require "intents/chord"
require "securerandom"

RSpec.describe Chord do
  def build_params_with_chord_and_session(acorde, session)
    {
      "queryResult" => {
        "parameters" => {
          "acorde" => acorde
        }
      },
      "session" => session
    }
  end

  describe "#process" do
    context "when it finds the harmonic field" do
      let!(:session) { SecureRandom.uuid}

      before do
        params = build_params_with_chord_and_session("A7", session)
        described_class.new(params).process
      end

      it "returns the appropriate fulfillment text" do
        params = build_params_with_chord_and_session("Gm7", session)
        result = described_class.new(params).process
        expect(result[:fulfillmentText]).to eq("Show! Sua música está no campo harmônico menor harmônico de ré.")
      end
    end
  end

  describe "#search_acorde_in_harmonic_field" do
    context "when it needs more chords to find out the harmonic field" do
      subject do
        described_class.new(build_params_with_chord_and_session("", "")).send(:search_acorde_in_harmonic_field, ["A7"])
      end

      it "returns more than one harmonic field" do
        expect(subject.size).to be > 1
      end
    end

    context "when it doesn't need more chords to find out the harmonic field" do
      subject do
        described_class.new(build_params_with_chord_and_session("", "")).send(:search_acorde_in_harmonic_field, ["A7", "Gm7"])
      end

      it "returns one harmonic field" do
        expect(subject.size).to eq(1)
      end
    end
  end
end
