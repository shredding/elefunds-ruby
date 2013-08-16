require 'rspec'
require 'json'
require_relative '../../lib/elefunds/rest_request'

describe RestRequest do

  before :each do
    @rest = RestRequest.new
  end

  let :valid_response do
    OpenStruct.new code: 200, body: {foo: 'bar'}.to_json
  end

  let :invalid_response do
    OpenStruct.new code: 401
  end

  let :expected_headers do
    {'Content-Type' => 'application/json', 'User-Agent' => 'elefunds-ruby 1.0.0'}
  end

  let :manipulated_headers do
    {'Content-Type' => 'some/type', 'User-Agent' => 'elefunds-ruby 1.0.0', 'Foo' => 'Bar'}
  end

  it 'makes a GET request and returns the json decoded response body' do
    @rest.class.stub(:get).with('https://elefunds.de', headers: expected_headers).and_return(valid_response)
    response = @rest.get 'https://elefunds.de'
    response.should == {'foo' => 'bar'}
  end

  it 'makes a POST request with body and returns the json decoded response body' do
    @rest.class.stub(:post).
        with('https://elefunds.de', body: 'data'.to_json, headers: expected_headers).
        and_return(valid_response)

    response = @rest.post 'https://elefunds.de', 'data'
    response.should == {'foo' => 'bar'}
  end

  it 'makes a PUT request with body and returns the json decoded response body' do
    @rest.class.stub(:put).
        with('https://elefunds.de', body: 'data'.to_json, headers: expected_headers).
        and_return(valid_response)

    response = @rest.put 'https://elefunds.de', 'data'
    response.should == {'foo' => 'bar'}
  end

  it 'makes a DELETE request and returns the json decoded response body' do
    @rest.class.stub(:delete).with('https://elefunds.de', headers: expected_headers).and_return(valid_response)
    response = @rest.delete 'https://elefunds.de'
    response.should == {'foo' => 'bar'}
  end

  it 'adds headers or overrides existing' do
    @rest.set_header 'Content-Type', 'some/type'
    @rest.set_header 'Foo', 'Bar'
    @rest.class.stub(:get).with('https://elefunds.de', headers: manipulated_headers).and_return(valid_response)
    @rest.get 'https://elefunds.de'
  end

  it 'raises elefunds communication exception if response code is different than 200' do
    expect { @rest.send(:process_response, invalid_response) }.to raise_exception Exceptions::ElefundsCommunicationException

  end
end