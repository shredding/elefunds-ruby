require 'httparty'
require 'json'

require_relative 'exceptions'
require_relative 'version'


class RestRequest

  API_URL = 'http://connect.elefunds.de'

  def initialize
    @headers = {
      'Content-Type' => 'application/json',
      'User-Agent'   => "elefunds-ruby #{Elefunds::VERSION}"
    }
  end

  def get(url)
    process_response HTTParty.get url, header: @headers
  end

  def post(url, data)
    process_response HTTParty.post url, body: data.to_json, header: @headers
  end

  def put(url, data = '')
    process_response HTTParty.put url, body: data.to_json, header: @headers
  end

  def delete(url)
    process_response HTTParty.delete url, header: @headers
  end

  def set_header(header, data)
    @headers[header] = data
  end

  protected
    def process_response(response)

      if response.code != 200
        raise Exceptions::ElefundsCommunicationException, "An error (#{response.code} occured: #{response.message}."
      end

      JSON.parse(response.body)
    end

end