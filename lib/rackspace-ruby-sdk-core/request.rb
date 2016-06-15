require 'json'
require 'rest-client'

class Peace::Request
  class << self
    def get(url)
      request! do
        Peace.logger.debug "GET: #{url}"
        RestClient.get(url, headers)
      end
    end

    def post(url, data)
      request! do
        Peace.logger.debug "POST: #{url}: #{data}"
        RestClient.post(url, data.to_json, headers)
      end
    end

    def put(url, data)
      request! do
        Peace.logger.debug "PUT: #{url}: #{data}"
        RestClient.put(url, data.to_json, headers)
      end
    end

    def delete(url)
      request! do
        Peace.logger.debug "DELETE: #{url}"
        RestClient.delete(url, headers) == ""
      end
    end

    private

    def request!(&block)
      JSON.parse(block.call)
    rescue Exception => e
      msg = JSON.parse(e.response)["badRequest"]["message"]
      raise Peace::BadRequest.new(msg)
    end

    def headers
      Peace::ServiceCatalog.load! unless Peace.auth_token
      { "X-Auth-Token": Peace.auth_token, content_type: :json, accept: :json }
    end
  end
end
