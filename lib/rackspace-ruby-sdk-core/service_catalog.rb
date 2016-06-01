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

  def self.load!(host)
    if host == :rackspace
      @catalog ||= begin
        Peace.logger.debug 'Loading ServiceCatalog'

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
    elsif host == :openstack
      raise "Not yet supported"
    else
      raise "Requires either :rackspace or :openstack as `host`"
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
