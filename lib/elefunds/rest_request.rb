require 'httparty'
require 'json'

require_relative 'exceptions'
require_relative 'version'


class RestRequest

  include HTTParty, Exceptions

  API_URL = 'http://connect.elefunds.de'

  def initialize
    @headers = {
      'Content-Type' => 'application/json',
      'User-Agent'   => "elefunds-ruby #{Elefunds::VERSION}"
    }
  end

  def get(url)
    process_response self.class.get url, headers: @headers
  end

  def post(url, data)
    process_response self.class.post url, body: data.to_json, headers: @headers
  end

  def put(url, data = '')
    process_response self.class.put url, body: data.to_json, headers: @headers
  end

  def delete(url)
    process_response self.class.delete url, headers: @headers
  end

  def set_header(header, data)
    @headers[header] = data
  end

  protected
    def process_response(response)

      if response.code != 200
        raise ElefundsCommunicationException, "An error (#{response.code} occurred: #{response.message}."
      end

      JSON.parse(response.body)
    end

end