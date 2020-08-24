require_relative "../../handler"

require "json"
require "securerandom"

RSpec.describe "Lambda Handler" do

  describe ".process" do

    context "when searching for an harmonic field" do
      let(:context) { nil }
      let(:event) do
        {
          "body" => {
            "session"     => SecureRandom.uuid,
            "queryResult" => {
              "intent" => {
                "displayName": "acorde"
              },
              "parameters" => {
                "acorde" => "A7"
              }
            }
          }.to_json
        }
      end

      subject { process(event: event, context: context) }

      let(:expected_fulfillment_text) do
        "Legal, o acorde pode estar no campo harmônico maior de ré, campo " \
        "harmônico menor harmônico de ré, campo harmônico menor melódico de " \
        "mi, campo harmônico menor melódico de ré, ou campo harmônico menor " \
        "natural de si. Fale-me outro acorde da mesma música."
      end

      it "returns the appropriate fulfillment text" do
        body = JSON.parse(subject[:body])
        expect(body["fulfillmentText"]).to eq(expected_fulfillment_text)
      end
    end

    context "when searching for a song cipher" do
      let(:context) { nil }
      let(:event) do
        {
          "body" => {
            "queryResult" => {
              "intent" => {
                "displayName": "cifra"
              },
              "parameters" => {
                "song" => "faroeste caboclo cifra"
              }
            }
          }.to_json
        }
      end

      subject { process(event: event, context: context) }

      it "returns the appropriate fulfillment text" do
        body = JSON.parse(subject[:body])
        expect(body["fulfillmentText"]).to include("Você pode acessar a cifra em:")
      end
    end

  end

end
