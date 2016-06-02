require 'spec_helper'

describe Peace::ServiceCatalog do

  it 'requires either an OpenStack or Rackspace-based catalog' do
    expect{ Peace::ServiceCatalog.load!('nope') }.to raise_error('Requires either :rackspace or :openstack as `host`')
  end

  describe "Rackspace-based catalogs" do
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
    let!(:catalog){ Peace::ServiceCatalog.load!(:openstack) }

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

end
