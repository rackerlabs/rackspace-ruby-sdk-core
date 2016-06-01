require 'spec_helper'

describe Peace::ServiceCatalog do

  it 'requires either an OpenStack or Rackspace-based catalog'
  it 'knows how to load OpenStack-based catalogs'
  it 'knows how to load Rackspace-based catalogs'
  it 'sets the tenant_id'
  it 'sets the auth_token'
  it 'knows which services are available'
  it 'knows the URL for a service based on name and region'

end
