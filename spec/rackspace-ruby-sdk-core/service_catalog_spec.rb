require 'spec_helper'

describe Peace::ServiceCatalog do

  it 'require ENV["SDK"] to be set' do
    expect{ Peace.service_catalog }.to raise_error RuntimeError
  end

  it 'requires either an OpenStack or Rackspace-based catalog' do
    expect{ Peace::ServiceCatalog.load!('nope') }.to raise_error('Requires either :rackspace or :openstack as `host`')
  end

end
