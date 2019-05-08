require 'json'

def process(event:, context:)
  { statusCode: 200, body: JSON.generate("Cipher!") }
end
