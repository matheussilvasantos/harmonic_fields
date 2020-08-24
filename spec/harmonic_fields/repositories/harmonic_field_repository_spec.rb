require "harmonic_fields/repositories/harmonic_field_repository"
require "harmonic_fields/entities/harmonic_field_entity"
require "harmonic_fields/value_objects/chord"

RSpec.describe HarmonicFields::Repositories::HarmonicFieldRepository do

  subject { described_class.new }

  describe "#find_by_chord" do

    context "when it searches for A#7" do
      let(:chord) { HarmonicFields::ValueObjects::Chord.new(name: "A#7") }
      let(:harmonic_fields) { subject.find_by_chord(chord) }

      it "returns 'campo harmônico menor harmônico de ré sustenido'" do
        expect(harmonic_fields.map(&:name)).to include("campo harmônico menor harmônico de ré sustenido")
      end

      it "returns 'campo harmônico menor melódico de ré sustenido'" do
        expect(harmonic_fields.map(&:name)).to include("campo harmônico menor melódico de ré sustenido")
      end
    end

  end

end
