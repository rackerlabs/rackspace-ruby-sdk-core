require 'rest-client'
require 'openssl'
require 'yaml'
require 'pry'

class Peace::ServiceCatalog

  RACKSPACE_AUTH_URL = "https://identity.api.rackspacecloud.com/v2.0/tokens"

  attr_accessor :id, :services, :access_token, :region, :tenant_id

  class << self
    def load!(host)
      info = case host
        when :rackspace then rackspace_based_auth
        when :openstack then openstack_based_auth
        else
          raise "Requires either :rackspace or :openstack as `host`"
        end

      auth_url  = info[:auth_url]
      body      = info[:body]
      region    = info[:region]

      headers   = {content_type: :json, accept: :json}
      response  = ::RestClient.post(auth_url, body, headers)
      body      = JSON.parse(response.body)

      hash      = body['access']['serviceCatalog']
      token     = body['access']['token']['id']
      tenant_id = body['access']['token']['tenant']['id']

      Peace::ServiceCatalog.new(hash, token, region, tenant_id)
    end

    private

    def rackspace_based_auth
      Peace.logger.debug 'Loading Rackspace ServiceCatalog'

      auth_url = RACKSPACE_AUTH_URL
      api_key  = ENV['RS_API_KEY']
      username = ENV['RS_USERNAME']
      region   = ENV['RS_REGION_NAME']
      body     = { "auth": { "RAX-KSKEY:apiKeyCredentials": { "apiKey": api_key, "username": username } } }.to_json
      { auth_url: auth_url, body: body, region: region }
    end

    def openstack_based_auth
      Peace.logger.debug 'Loading OpenStack ServiceCatalog'

      auth_url = ENV['OS_AUTH_URL']
      username = ENV['OS_USERNAME']
      password = ENV['OS_PASSWORD']
      tenant   = ENV['OS_TENANT_NAME']
      body     = { "auth": { "tenantName": "#{tenant}", "passwordCredentials": { "username": "#{username}", "password": "#{password}" } } }.to_json
      { auth_url: auth_url, body: body, region: nil }
    end
  end

  def initialize(hash, token, region, tenant_id)
    @access_token    = token
    @region          = region
    @services        = hash.map{ |s| Service.new(s) }
    Peace.tenant_id  = tenant_id
    Peace.auth_token = token
  end

  def available_services
    names = services.map(&:name).inject([]) do |memo, rax_name|
      service = Peace::SERVICE_NAME_MAP.find{|k,v| v == rax_name }
      memo << service[0] if service
      memo
    end.sort

    names.map{ |name| Peace::SERVICE_KLASSES[name] }.compact
  end

  def url_for(our_service_name)
    service = services.find do |s|
      s.name == Peace::SERVICE_NAME_MAP[our_service_name]
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
