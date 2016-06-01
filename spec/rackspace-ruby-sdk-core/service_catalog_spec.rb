require 'spec_helper'

describe Peace::ServiceCatalog do

  it 'requires either an OpenStack or Peace-based catalog' do
    expect{ Peace::ServiceCatalog.load!('nope') }.to raise_error('Requires either :rackspace or :openstack as `host`')
  end

  describe "Peace-based catalogs" do
    let!(:catalog){ Peace::ServiceCatalog.load!(:rackspace) }

    it 'sets the tenant_id globally' do
      expect(Peace.tenant_id).not_to be_nil
    end

    it 'sets the auth_token globally' do
      expect(Peace.auth_token).not_to be_nil
    end

    it 'sets the catalog globally' do
      expect(Peace.service_catalog).not_to be_nil
    end

    it 'knows which services are available' do
      expect(Peace.service_catalog.available_services).not_to be_nil
    end

    it 'knows the URL for a service based on name and region' do
      expect(Peace.service_catalog.url_for('compute')).not_to be_nil
    end
  end

  describe "OpenStack-based catalogs" do
    it 'sets the tenant_id'
    it 'sets the auth_token'
    it 'knows which services are available'
    it 'knows the URL for a service based on name and region'
  end

end
