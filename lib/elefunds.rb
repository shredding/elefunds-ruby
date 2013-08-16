require 'digest/sha1'

require_relative 'elefunds/rest_request'
require_relative 'elefunds/exceptions'
require_relative 'patches/string'


class ElefundsFacade

  include Exceptions

  attr_accessor :client_id
  attr_accessor :api_key
  attr_accessor :country_code
  attr_accessor :configuration

  def initialize(client_id, api_key, country_code = 'de')
    @client_id, @api_key, @country_code = client_id, api_key, country_code
    @cached_receivers = []
    @hashed_key = calculate_hashed_key
    @rest = set_rest_request
  end

  def receivers(force_reload = false)
    return @cached_receivers if force_reload && @cached_receivers.length == 0

    response = @rest.get RestRequest::API_URL + "/receivers/for/#{@client_id}"

    if response['receivers'].has_key? @country_code
      @cached_receivers = response['receivers'][@country_code]
    else
      raise ElefundsException, "Country code #{@country_code} is not registered for given client."
    end

    @cached_receivers
  end

  # Shortcut for adding a single donation
  def add_donation(donation)
    add_donations [donation]
  end

  def add_donations(donations)
    donations = make_donations_api_compatible donations
    @rest.post RestRequest::API_URL + "/donations/?clientId=#{@client_id}&hashedKey=#{@hashed_key}", donations
  end

  # Shortcut for cancelling a single donation
  def cancel_donation(donation)
    cancel_donations [donation]
  end

  # Accepts foreign ids or full blown donation hashes
  def cancel_donations(donations)
    donations.collect!(&method(:extract_foreign_ids))
    @rest.delete RestRequest::API_URL + "/donations/#{donations.join(',')}/?clientId=#{@client_id}&hashedKey=#{@hashed_key}"
  end

  # Shortcut for completing a single donation
  def complete_donation(donation)
    complete_donations [donation]
  end

  # Accepts foreign ids or full blown donation hashes
  def complete_donations(donations)
    donations.collect!(&method(:extract_foreign_ids))
    @rest.put RestRequest::API_URL + "/donations/#{donations.join(',')}/?clientId=#{@client_id}&hashedKey=#{@hashed_key}"
  end

  def set_rest_request(request = RestRequest.new)
    @rest = request
    @rest.set_header 'User-Agent', "elefunds-ruby #{Elefunds::VERSION}"
    @rest
  end

  def set_user_agent(user_agent)
    @rest.set_header 'User-Agent', user_agent
  end

  protected

    def calculate_hashed_key
      Digest::SHA1.hexdigest client_id.to_s + api_key
    end

    # The api standard is camelCase instead of snake_case
    # We do as well normalize some data like DateTime to iso8601 string!
    def make_donations_api_compatible(donations)
      donations.collect! do |donation|
        donation.inject({}) do | prepared_donation, (key, value)|

          value = value.iso8601 if value.is_a? DateTime

          if value.is_a? Hash
            value = value.inject({}) do |data, (inner_key, inner_value)|
              data[inner_key.to_s.lower_camel_case] = inner_value
              data
            end
          end

          prepared_donation[key.to_s.lower_camel_case] = value
          prepared_donation
        end
      end
    end

    def extract_foreign_ids(donation)
        if donation.is_a? Hash
          donation[:foreign_id]
        elsif donation.is_a? String
          donation
        end
    end
end