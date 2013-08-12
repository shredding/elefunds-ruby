require_relative '../lib/elefunds'
require_relative '../lib/elefunds/version'
require_relative '../lib/elefunds/exceptions'


describe ElefundsFacade do

  before :each do
    @elefunds = ElefundsFacade.new 1001, 'ay3456789gg234561234'
    @fake_receivers = {
        'receivers' => {
            'de' => 'foo'
        }
    }
    @request_receiver_stub = double set_header: nil
  end

  it 'should create a hashed key from given client_id and api_key' do
    hashed_key = @elefunds.send :calculate_hashed_key
    hashed_key.should eql 'eb85fa24f23b7ade5224a036b39556d65e764653'
  end

  it 'should set rest request and user agent to elefunds ruby version' do
    @request_receiver_stub.should_receive(:set_header).with('User-Agent', "elefunds-ruby #{Elefunds::VERSION  }")
    @elefunds.set_rest_request @request_receiver_stub
  end

  it 'should return a set of receivers' do
    @elefunds.set_rest_request @request_receiver_stub
    @request_receiver_stub.should_receive(:get).with('http://connect.elefunds.de/receivers/for/1001').and_return(@fake_receivers)
    receivers  = @elefunds.receivers
    receivers.should eql 'foo'
  end

  it 'should return the cached receivers if force reload is set to true' do
    @elefunds.set_rest_request @request_receiver_stub
    receivers = @elefunds.receivers force_reload: true
    receivers.should eql []
  end

  it 'should raise an elefunds exception if country code is not given' do
    elefunds = ElefundsFacade.new 1001, 'ay3456789gg234561234', 'en'

    @request_receiver_stub.should_receive(:get).and_return(@fake_receivers)
    elefunds.set_rest_request @request_receiver_stub

    expect { elefunds.receivers }.to raise_exception Exceptions::ElefundsException
  end


end