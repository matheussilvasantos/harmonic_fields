require "harmonic_fields/services/harmonic_field_finder"
require "harmonic_fields/value_objects/chord"

require "securerandom"

RSpec.describe HarmonicFields::Services::HarmonicFieldFinder do

  def build_params_with_chord_and_session(chord, session)
    {
      :chord      => chord,
      :session_id => session
    }
  end

  describe "#process" do

    context "when it finds the harmonic field" do
      let!(:session) { SecureRandom.uuid}

      before do
        params = build_params_with_chord_and_session("A7", session)
        described_class.new(params).process
      end

      it "returns the appropriate message" do
        params = build_params_with_chord_and_session("Gm7", session)
        result = described_class.new(params).process
        expect(result).to eq("Show! Sua música está no campo harmônico menor harmônico de ré.")
      end
    end

  end

  describe "#search_chord_in_harmonic_field" do

    context "when it needs more chords to find out the harmonic field" do
      subject do
        params = build_params_with_chord_and_session("", "")
        chords = [HarmonicFields::ValueObjects::Chord.new(name: "A7")]
        described_class.new(params).send(:search_chord_in_harmonic_field, chords)
      end

      it "returns more than one harmonic field" do
        expect(subject.size).to be > 1
      end
    end

    context "when it doesn't need more chords to find out the harmonic field" do
      subject do
        params = build_params_with_chord_and_session("", "")
        chords = [
          HarmonicFields::ValueObjects::Chord.new(name: "A7"),
          HarmonicFields::ValueObjects::Chord.new(name: "Gm7")
        ]
        described_class.new(params).send(:search_chord_in_harmonic_field, chords)
      end

      it "returns one harmonic field" do
        expect(subject.size).to eq(1)
      end
    end

  end

end
