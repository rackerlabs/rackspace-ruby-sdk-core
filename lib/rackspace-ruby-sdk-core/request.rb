require 'json'
require 'rest-client'

class Peace::Request
  class << self
    def get(url)
      request! do
        Peace.logger.debug "GET: #{url}"
        response = RestClient.get(url, headers)
        Peace.logger.debug response
        response
      end
    end

    def post(url, data)
      request! do
        Peace.logger.debug "POST: #{url}: #{data.to_json}"
        response = RestClient.post(url, data.to_json, headers)
        Peace.logger.debug response
        response
      end
    end

    def put(url, data)
      request! do
        Peace.logger.debug "PUT: #{url}: #{data.to_json}"
        response = RestClient.put(url, data.to_json, headers)
        Peace.logger.debug response
        response
      end
    end

    def delete(url)
      request! do
        Peace.logger.debug "DELETE: #{url}"
        response = RestClient.delete(url, headers)
        Peace.logger.debug response
        response
      end
    end

    private

    def request!(&block)
      response = block.call
      response == "" ? true : JSON.parse(response)
    rescue JSON::ParserError => e
      raise Peace::BadRequest.new(e)
    rescue RestClient::Conflict => e
      raise Peace::BadRequest.new(e.response)
    rescue RestClient::BadRequest => e
      raise Peace::BadRequest.new(e.response)
    end

    def headers
      Peace::ServiceCatalog.load! unless Peace.auth_token
      { "X-Auth-Token": Peace.auth_token, content_type: :json, accept: :json }
    end
  end
end
