require 'spec_helper'

module Testing
  module Compute
    class Server < Peace::Model
    end
  end
end

describe Peace::Model do
  let(:model){ Testing::Compute::Server.new }

  it 'knows the resource_name at object level' do
    expect(model.resource_name).to eq 'server'
  end

  it 'knows the resource_name at class level' do
    expect(model.class.resource_name).to eq 'server'
  end

  it 'knows how to serialize into json' do
    expect(model.to_json).to eq "{\"server\":{}}"
  end

end
