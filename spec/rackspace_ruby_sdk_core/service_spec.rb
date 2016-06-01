require 'spec_helper'

module Testing
  class Network < Peace::Service
  end
end

describe Peace::Service do
  let(:service){ Testing::Network.new }

  it 'knows the service_name' do
    expect(service.class.service_name).to eq :network
  end

end
