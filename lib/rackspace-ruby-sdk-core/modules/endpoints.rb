ENV['SDK'] = "openstack"
ENV['SC_STUB'] = "true"

module Peace::Endpoints

  class EndpointCollection
    attr_accessor :endpoints

    class Endpoint
      attr_accessor :action, :url, :method, :payload, :headers
    end

    REST = [
      { method: :delete, action: :destroy, on: :member },
      { method: :get, action: :index, on: :collection },
      { method: :get, action: :show, on: :member },
      { method: :post, action: :create, on: :collection },
      { method: :put, action: :update, on: :member }
    ]

    def initialize(obj)
      if is_class_level?(obj)
        m_url = ""
        c_url = obj.collection_url
      else
        m_url = obj.url
        c_url = obj.class.collection_url
      end

      @endpoints = REST.map do |r|
        ep        = Endpoint.new
        ep.url    = ( r[:on] == :collection ) ? c_url : m_url
        ep.action = r[:action]
        ep.method = r[:method]
        ep
      end
    end

    def is_class_level?(obj)
      obj.singleton_class.included_modules.include?(Peace::ORM::ClassMethods)
    end

    def method_missing(method_sym, *arguments, &block)
      @endpoints.find{ |e| e.action == method_sym } || super
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def endpoints
    EndpointCollection.new(self)
  end

  private

  module ClassMethods
    def endpoints
      EndpointCollection.new(self)
    end
  end

end
