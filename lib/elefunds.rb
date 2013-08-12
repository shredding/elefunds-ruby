require 'digest/sha1'

require_relative 'elefunds/rest_request'
require_relative 'elefunds/exceptions'
require_relative 'patches/string'

# The elefunds facade for abstracting access to the elefunds API.
#
# Author::    Christian Peters (mailto:christian@elefunds.de)
# Copyright:: Copyright (c) 2013 elefunds GmbH
# License::   BSD-3

# If you need more information or credentials, please feel free
# to write to contact@elefunds.de
#
# If you only want to do some test, please use a test client account,
# such as 1001 / ay3456789gg234561234
#
# Receivers are returned as an array of hashes:
#
# [{"name" => "Beispiel 01",
#   "images" =>
#     {"horizontal" =>
#       {"small"  => "http://img.url/hs.jpg",
#        "medium" => "http://img.url/hm.jpg",
#        "large"  => "http://img.url/hl.jpg",
#       },
#     "vertical"=>
#       {"small"  => "http://img.url/hs.jpg",
#        "medium" => "http://img.url/hm.jpg",
#        "large"  => "http://img.url/hl.jpg",
#       },
#    "description"=>"Beispiel Organisation 01",
#    "id"=>4
# }]
#
# Donations are expected as hashes, as well
# {
#    foreign_id:           'AB12345',              # a unique id per donation, e.g. the order id in a shop
#    donation_timestamp:   DateTime.now,           # you can as well pass an iso8601 compatible string
#    donation_amount:      300,                    # donation amount in cent
#    receivers:            [1,2],                  # receiver IDs of the selected receivers
#    receivers_available:  [1,2,3],                # all receivers that were available to the user
#    grand_total:          900,                    # the grand total prior to the donation (optional)
#    suggested_amount:     100                     # the amount that was suggested to the user
# }
#
# If you want, you can add a 'donator' as key to the donations and we will send him a donation receipt!
# The donator itself must be a hash like this:
#
# {
#   first_name:           'Christian',
#   last_name:            'Peters',
#   email:                'christian@elefunds.de',
#   street_address:       'Schönhauser Allee 124',
#   zip:                  '10234'
#   city:                 'Berlin',
#   country_code:         'de'
# }

class ElefundsFacade

  attr_accessor :client_id
  attr_accessor :api_key
  attr_accessor :country_code
  attr_accessor :configuration

  def initialize(client_id, api_key, country_code = 'de')
    @client_id, @api_key, @country_code, @configuration = client_id, api_key, country_code, configuration

    @hashed_key = calculate_hashed_key
    @rest = set_request
    @cached_receivers = []
  end

  def set_user_agent(user_agent)
    @rest.set_header 'User-Agent', user_agent
  end

  def receivers(force_reload = false)

    return @cached_receivers unless force_reload && @cached_receivers.length > 0

    response = @rest.get RestRequest::API_URL + "/receivers/for/#{@client_id}"

    if response['receivers'].has_key? @country_code
      @cached_receivers = response['receivers'][@country_code]
    else
      raise Exceptions::ElefundsException, "Country code #{@country_code} is not registered for given client."
    end

    @cached_receivers
  end

  # Shortcut for adding a single donation
  def add_donation(donation)
    add_donations [donation]
  end

  # Adds multiple donations to the API
  def add_donations(donations)
    donations = make_donations_api_compatible donations
    @rest.post RestRequest::API_URL + "/donations/?clientId=#{@client_id}&hashedKey=#{@hashed_key}", donations
  end

  # Shortcut for cancelling a single donation
  # Accepts foreign ids or full blown donation hashes
  def cancel_donation(donation)
    cancel_donations [donation]
  end

  # Accepts foreign ids or full blown donation hashes
  def cancel_donations(donations)
    donations.collect!(&method(:extract_foreign_ids))
    @rest.delete RestRequest::API_URL + "/donations/#{donations.join(',')}/?clientId=#{@client_id}&hashedKey=#{@hashed_key}"
  end

  # Shortcut for completing a single donation
  # Accepts foreign ids or full blown donation hashes
  def complete_donation(donation)
    complete_donations [donation]
  end

  # Accepts foreign ids or full blown donation hashes
  def complete_donations(donations)
    donations.collect!(&method(:extract_foreign_ids))
    @rest.put RestRequest::API_URL + "/donations/#{donations.join(',')}/?clientId=#{@client_id}&hashedKey=#{@hashed_key}"
  end

  protected

    def calculate_hashed_key
      Digest::SHA1.hexdigest client_id.to_s + api_key
    end

    def set_request(request = RestRequest.new)
      request
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
          donation['foreign_id']
        elsif donation.is_a? String
          donation
        end
    end
end