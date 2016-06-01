require 'rest-client'
require 'openssl'
require 'yaml'
require 'pry'

class Peace::ServiceCatalog

  if ENV['RACKSPACE_MOCK'] == 'true'
    BASE_URL = "http://openstack.dev/v2.0/tokens"
  else
    BASE_URL = "https://identity.api.rackspacecloud.com/v2.0/tokens"
  end

  attr_accessor :id, :services, :access_token, :region, :tenant_id

  def self.load!
    @catalog ||= begin
      Rackspace.logger.debug 'Loading ServiceCatalog'

      # qAZomDJMvaMxf7ajFPhpV8tQy

      api_key   = ENV['RS_API_KEY']
      username  = ENV['RS_USERNAME']
      region    = ENV['RS_REGION_NAME']
      headers   = {content_type: :json, accept: :json}
      body      = { "auth": { "RAX-KSKEY:apiKeyCredentials": { "apiKey": api_key, "username": username } } }
      response  = ::RestClient.post(BASE_URL, body.to_json, headers)
      body      = JSON.parse(response.body)
      hash      = body['access']['serviceCatalog']
      token     = body['access']['token']['id']
      tenant_id = body['access']['token']['tenant']['id']

      Peace::ServiceCatalog.new(hash, token, region, tenant_id)
    end
  end

  def initialize(hash, token, region, tenant_id)
    @access_token        = token
    @region              = region
    @services            = hash.map{ |s| Service.new(s) }
    Rackspace.tenant_id  = tenant_id
    Rackspace.auth_token = token
  end

  def available_services
    names = services.map(&:name).inject([]) do |memo, rax_name|
      service = Rackspace::SERVICE_NAME_MAP.find{|k,v| v == rax_name }
      memo << service[0] if service
      memo
    end.sort

    services = names.map{ |name| Rackspace::SERVICE_KLASSES[name] }.compact
    services.map{ |s| s.constantize }
  end

  def url_for(our_service_name)
    service = services.find do |s|
      s.name == Rackspace::SERVICE_NAME_MAP[our_service_name]
    end

    if service
      endpoints = service.endpoints

      if endpoints.size == 1 # regionless
        endpoints.first.public_url
      else
        endpoints.find{ |e| e.region.downcase == region.downcase }.public_url
      end
    else
      raise "No service '#{our_service_name}' found"
    end
  rescue Exception => e
    raise "No #{our_service_name} endpoint for #{region}"
  end


  class Service
    attr_accessor :id, :name, :endpoints

    def initialize(hash)
      @name      = hash['name']
      @endpoints = hash['endpoints'].map{ |ep| Endpoint.new(ep) }

      if Rackspace.mocking?
        @endpoints.each do |ep|
          begin
            friendly_name = Rackspace::SERVICE_NAME_MAP.find{ |(k,v)| v == name }[0]
            ep.public_url = "http://localhost:7000/#{friendly_name}"
          rescue Exception => e
            Rackspace.logger.error "Could not mock '#{friendly_name}' (#{e})"
          end
        end
      end
    end


    class Endpoint
      attr_accessor :id, :region, :tenant_id, :public_url, :internal_url

      def initialize(hash)
        @region       = hash['region']
        @tenant_id    = hash['tenantId']
        @public_url   = hash['publicURL']
        @internal_url = hash['internalURL']
      end
    end
  end

end
