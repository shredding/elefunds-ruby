require_relative '../lib/elefunds'
require_relative '../lib/elefunds/version'
require_relative '../lib/elefunds/exceptions'


describe ElefundsFacade do

  before :each do
    @elefunds = ElefundsFacade.new 1001, 'ay3456789gg234561234'
    @fake_request = double set_header: nil
  end

  let :fake_receivers do
    {
        'receivers' => {
            'de' => 'foo'
        }
    }
  end

  let :fake_donation do
    {
        foreign_id:           'AB12345',
        donation_timestamp:   DateTime.new(2013, 1, 1),
        donation_amount:      300,
        receivers:            [1,2],
        receivers_available:  [1,2,3],
        grand_total:          900,
        suggested_amount:     100,
        donator: {
            first_name:           'Christian',
            last_name:            'Peters',
            email:                'christian@elefunds.de',
            street_address:       'Schönhauser Allee 124',
            zip:                  '10234',
            city:                 'Berlin',
            country_code:         'de'
        }
    }
  end

  let :api_compatible_donations do
      [
        {
            'foreignId'          => 'AB12345',
            'donationTimestamp'  => '2013-01-01T00:00:00+00:00',
            'donationAmount'     => 300,
            'receivers'          =>[1, 2],
            'receiversAvailable' =>[1, 2, 3],
            'grandTotal'         =>900,
            'suggestedAmount'    =>100,
            'donator'            => {
                'firstName'     => 'Christian',
                'lastName'      => 'Peters',
                'email'         => 'christian@elefunds.de',
                'streetAddress' => 'Schönhauser Allee 124',
                'zip'           => '10234',
                'city'          => 'Berlin',
                'countryCode'   => 'de'
            }
        }
    ]
  end


  it 'creates a hashed key from given client_id and api_key' do
    hashed_key = @elefunds.send :calculate_hashed_key
    hashed_key.should eql 'eb85fa24f23b7ade5224a036b39556d65e764653'
  end

  it 'sets rest request and user agent to elefunds ruby version' do
    @fake_request.should_receive(:set_header).with('User-Agent', "elefunds-ruby #{Elefunds::VERSION  }")
    @elefunds.set_rest_request @fake_request
  end

  it 'returns a set of receivers' do
    @elefunds.set_rest_request @fake_request
    @fake_request.should_receive(:get).with('http://connect.elefunds.de/receivers/for/1001').and_return(fake_receivers)
    receivers  = @elefunds.receivers
    receivers.should eql 'foo'
  end

  it 'returns the cached receivers if force reload is set to true' do
    @elefunds.set_rest_request @fake_request
    receivers = @elefunds.receivers force_reload: true   
    receivers.should eql []
  end

  it 'raises an elefunds exception if country code is not given' do
    elefunds = ElefundsFacade.new 1001, 'ay3456789gg234561234', 'en'

    @fake_request.should_receive(:get).and_return(fake_receivers)
    elefunds.set_rest_request @fake_request

    expect { elefunds.receivers }.to raise_exception Exceptions::ElefundsException
  end

  it 'sends an api compatible JSON to the API' do
    api_url = 'http://connect.elefunds.de/donations/?clientId=1001&hashedKey=eb85fa24f23b7ade5224a036b39556d65e764653'

    @fake_request.should_receive(:post).with(api_url, api_compatible_donations)
    @elefunds.set_rest_request @fake_request
    @elefunds.add_donation fake_donation
  end

  it 'accepts an iso string as donation timestamp' do
    @fake_request.should_receive(:post)
    fake_donation[:donator][:donation_timestamp] = '2013-01-01T00:00:00+00:00'

    @elefunds.set_rest_request @fake_request
    @elefunds.add_donation fake_donation
  end

  it 'sends a delete request to the API when a donation is cancelled' do
    api_url = 'http://connect.elefunds.de/donations/foreign_id/?clientId=1001&hashedKey=eb85fa24f23b7ade5224a036b39556d65e764653'
    @fake_request.should_receive(:delete).with(api_url)
    @elefunds.set_rest_request @fake_request
    @elefunds.cancel_donations %w(foreign_id)
  end

  it 'accepts a donation hash for cancellation' do
    api_url = 'http://connect.elefunds.de/donations/AB12345/?clientId=1001&hashedKey=eb85fa24f23b7ade5224a036b39556d65e764653'
    @fake_request.should_receive(:delete).with(api_url)
    @elefunds.set_rest_request @fake_request
    @elefunds.cancel_donation fake_donation
  end

  it 'sends a put request to the API when a donation is completed' do
    api_url = 'http://connect.elefunds.de/donations/foreign_id/?clientId=1001&hashedKey=eb85fa24f23b7ade5224a036b39556d65e764653'
    @fake_request.should_receive(:put).with(api_url)
    @elefunds.set_rest_request @fake_request
    @elefunds.complete_donations %w(foreign_id)
  end

  it 'accepts a donation hash for completion' do
    api_url = 'http://connect.elefunds.de/donations/AB12345/?clientId=1001&hashedKey=eb85fa24f23b7ade5224a036b39556d65e764653'
    @fake_request.should_receive(:put).with(api_url)
    @elefunds.set_rest_request @fake_request
    @elefunds.complete_donation fake_donation
  end

  it 'provides a shortcut method for setting the user agent on the rest request instance' do
    @elefunds.set_rest_request @fake_request
    @fake_request.should_receive(:set_header).with('User-Agent', 'Sure as hell not IE')
    @elefunds.set_user_agent 'Sure as hell not IE'
  end

end