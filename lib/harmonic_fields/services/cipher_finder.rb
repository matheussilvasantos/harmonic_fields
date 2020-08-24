# frozen_string_literal: true

require "httparty"
require "nokogiri"

module HarmonicFields
  module Services

    class CipherFinder
      def initialize(params)
        @song = params[:song]
      end

      def process
        response = search_cipher_on_google
        link = get_first_link_from_google(response)
        build_message(link)
      end

      private

      def search_cipher_on_google
        url = "https://www.google.com/search?q=#{@song}+cifra"
        headers = {
          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:79.0) Gecko/21111111 Firefox/79.0"
        }
        HTTParty.get(url, :headers => headers)
      end

      FIRST_LINK_SELECTOR = "div[data-async-context^='query'] a:first-of-type"
      def get_first_link_from_google(html)
        doc = Nokogiri::HTML(html)
        link = doc.css(FIRST_LINK_SELECTOR).first["href"].match(/http.*/).to_s
      end

      def build_message(link)
        "Você pode acessar a cifra em: #{link}"
      end
    end

  end
end
