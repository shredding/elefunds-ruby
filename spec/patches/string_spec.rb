require 'rspec'
require_relative '../../lib/patches/string'

describe String do

  it 'changes snake cases to lower camel case' do
    'a_snake_case'.lower_camel_case.should == 'aSnakeCase'
    'Starting_with_upper'.lower_camel_case.should == 'startingWithUpper'
  end

end