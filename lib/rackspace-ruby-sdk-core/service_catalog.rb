require 'rest-client'
require 'openssl'
require 'yaml'
require 'pry'

class Peace::ServiceCatalog

  RACKSPACE_AUTH_URL = "https://identity.api.rackspacecloud.com/v2.0/tokens"

  attr_accessor :id, :services, :access_token, :region

  class << self
    def load!(host)
      info = case host.to_sym
        when :rackspace then rackspace_based_auth
        when :openstack then openstack_based_auth
        else
          raise "Requires either :rackspace or :openstack as `host`"
        end

      if ENV['SC_STUB'] == 'true'
        file  = File.read("#{Dir.pwd}/spec/support/service_catalog.json")
        token = "TEST_TOKEN"
        body  = JSON.parse(file)
      else
        auth_url = info[:auth_url]
        body     = info[:body]
        region   = info[:region]
        headers  = { content_type: :json, accept: :json }
        response = ::RestClient.post(auth_url, body, headers)
        token    = response.headers[:x_subject_token]
        body     = JSON.parse(response.body)
      end

      catalog = body['token']['catalog']
      Peace::ServiceCatalog.new(catalog, token, host)
    end

    private

    def rackspace_based_auth
      Peace.logger.debug 'Loading Rackspace ServiceCatalog'

      auth_url = RACKSPACE_AUTH_URL
      api_key  = ENV['RS_API_KEY']
      username = ENV['RS_USERNAME']
      region   = ENV['RS_REGION_NAME']

      raise "ENV['RS_API_KEY'] not set" unless api_key
      raise "ENV['RS_USERNAME'] not set" unless username
      raise "ENV['RS_REGION_NAME'] not set" unless region

      body = {
        "auth": {
          "RAX-KSKEY:apiKeyCredentials": {
            "apiKey": api_key,
            "username": username
          }
        }
      }

      { auth_url: auth_url, body: body.to_json, region: region }
    end

    def openstack_based_auth
      Peace.logger.debug 'Loading OpenStack ServiceCatalog'

      auth_url   = ENV['OS_AUTH_URL']
      username   = ENV['OS_USERNAME']
      password   = ENV['OS_PASSWORD']
      tenant     = ENV['OS_TENANT_NAME']
      tenant_id  = ENV['OS_TENANT_ID']
      project_id = ENV['OS_PROJECT_ID']
      region     = ENV['OS_REGION_NAME']

      raise "ENV['OS_AUTH_URL'] not set" unless auth_url
      raise "ENV['OS_USERNAME'] not set" unless username
      raise "ENV['OS_PASSWORD'] not set" unless password
      raise "ENV['OS_TENANT_NAME'] not set" unless tenant
      raise "ENV['OS_TENANT_ID'] not set" unless tenant_id
      raise "ENV['OS_PROJECT_ID'] not set" unless project_id
      raise "ENV['OS_REGION_NAME'] not set" unless region

      if auth_url =~ /v3$/
        auth_url = "#{auth_url}/auth/tokens"
      end

      body = {
        "auth": {
          "identity": {
            "methods": ["password"],
            "password": {
              "user": {
                "id": "#{tenant_id}",
                "password": "#{password}"
              }
            }
          },
          "scope": {
            "project": {
              "id": "#{project_id}"
            }
          }
        }
      }

      { auth_url: auth_url, body: body.to_json, region: region }
    end
  end

  def initialize(catalog, token, sdk)
    @access_token    = token
    @region          = ENV['OS_REGION_NAME']
    @services        = catalog.map{ |s| Service.new(s) }
    Peace.tenant_id  = ENV['OS_PROJECT_ID']
    Peace.auth_token = token
    Peace.sdk        = sdk
  end

  def available_services
    names = services.map(&:name).inject([]) do |memo, rax_name|
      service = ::SERVICE_NAME_MAP.find{|k,v| v == rax_name }
      memo << service[0] if service
      memo
    end.sort

    names.map{ |name| ::SERVICE_KLASSES[name] }.compact
  end

  def url_for(our_service_name)
    service = services.find do |s|
      s.name == ::SERVICE_NAME_MAP[our_service_name]
    end

    if service
      endpoints = service.endpoints

      if endpoints.size == 1 # regionless
        endpoints.first.url
      else
        endpoints.find do |e|
          e.region == region.downcase && e.interface == "public"
        end.url
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
      attr_accessor :id, :region, :url, :interface

      def initialize(hash)
        @id        = hash['id']
        @region    = hash['region'].downcase
        @url       = hash['url']
        @interface = hash['interface']
      end
    end
  end

end
