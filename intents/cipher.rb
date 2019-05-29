# frozen_string_literal: true

require "httparty"
require "nokogiri"

class Cipher
  def initialize(params)
    @song = params.dig("queryResult", "parameters", "song")
  end

  def process
    response = search_cipher_on_google
    link = get_first_link_from_google(response)
    build_response(link)
  end

  private

  def search_cipher_on_google
    HTTParty.get("https://www.google.com/search?q=#{@song}+cifra")
  end

  FIRST_LINK_SELECTOR = "#search a:first-of-type"
  def get_first_link_from_google(html)
    doc = Nokogiri::HTML(response)
    link = doc.css(FIRST_LINK_SELECTOR).first["href"].match(/http.*/).to_s
  end

  def build_response
    {
      followupEventInput: {
        name: "cifra-found",
        languageCode: "pt-BR",
        parameters: {
          "cifra" => link
        }
      }
    }
  end
end
