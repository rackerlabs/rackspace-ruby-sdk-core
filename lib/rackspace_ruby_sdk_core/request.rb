require 'json'
require 'rest-client'

class Peace::Request
  class << self
    def get(url)
      Rackspace.logger.debug "GET: #{url}"
      request = RestClient.get(url, headers)
      JSON.parse(request)
    end

    def post(url, data)
      Rackspace.logger.debug "POST: #{url}: #{data}"
      request = RestClient.post(url, data.to_json, headers)
      JSON.parse(request)
    end

    def put(url, data)
      Rackspace.logger.debug "PUT: #{url}: #{data}"
      request = RestClient.put(url, data.to_json, headers)
      JSON.parse(request)
    end

    def delete(url)
      Rackspace.logger.debug "DELETE: #{url}"
      RestClient.delete(url, headers) == ""
    end

    private

    def headers
      Peace::ServiceCatalog.load! unless Rackspace.auth_token
      { "X-Auth-Token": Rackspace.auth_token, content_type: :json, accept: :json }
    end
  end
end
