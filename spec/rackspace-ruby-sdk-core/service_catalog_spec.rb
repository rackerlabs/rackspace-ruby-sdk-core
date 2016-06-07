require 'spec_helper'

describe Peace::ServiceCatalog do

  it 'requires either an OpenStack or Rackspace-based catalog' do
    expect{ Peace::ServiceCatalog.load!('nope') }.to raise_error('Requires either :rackspace or :openstack as `host`')
  end

end
