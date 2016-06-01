require 'json'
require 'rest-client'

class Peace::Request
  class << self
    def get(url)
      Peace.logger.debug "GET: #{url}"
      request = RestClient.get(url, headers)
      JSON.parse(request)
    end

    def post(url, data)
      Peace.logger.debug "POST: #{url}: #{data}"
      request = RestClient.post(url, data.to_json, headers)
      JSON.parse(request)
    end

    def put(url, data)
      Peace.logger.debug "PUT: #{url}: #{data}"
      request = RestClient.put(url, data.to_json, headers)
      JSON.parse(request)
    end

    def delete(url)
      Peace.logger.debug "DELETE: #{url}"
      RestClient.delete(url, headers) == ""
    end

    private

    def headers
      Peace::ServiceCatalog.load! unless Peace.auth_token
      { "X-Auth-Token": Peace.auth_token, content_type: :json, accept: :json }
    end
  end
end
