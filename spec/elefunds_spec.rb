require_relative '../lib/elefunds'


describe ElefundsFacade do

  it 'should create the hashed key from given client_id and api_key' do
    elefunds = ElefundsFacade.new 1001, 'ay3456789gg234561234'
    puts  elefunds.send global_variables
  end

end