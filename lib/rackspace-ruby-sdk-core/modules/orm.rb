module Peace::ORM

  def self.included(klass)
    klass.extend ClassMethods
  end

  def save
    method   = self.id.present? ? 'put' : 'post'
    response = Peace::Request.send(method, self.url, self)
    self.send(:refresh!, response)
  end

  def destroy
    Peace::Request.delete(self.url)
  end

  def reload
    response = Peace::Request.get(self.url)
    self.send(:refresh!, response)
  end

  # Provide the URL based on object state
  def url
    url = self.class.collection_url
    url << "/#{id}" if self.id
    url
  end


  module ClassMethods

    def all(attrs={})
      response = Peace::Request.get(collection_url(attrs))
      objs     = response[@json_key_name || collection_name]

      [*objs].map do |f|
        o = self.new(f)
        o.reload if ENV['PREFETCH'] == "true"
        o
      end
    end

    # Find a particular object
    def find(id)
      all.find{ |o| o.id == id.to_s }
    end

    # Get the first object
    def first
      all.first
    end

    def create(options={})
      wrapper  = collection_name.singularize
      payload  = {"#{wrapper}" => options}
      response = Peace::Request.post(collection_url, payload)

      self.new(response)
    end

    # A Mustache-inspired templated string that overrides
    # default naming conventions and injects nested URL variables.
    def rackspace_api_path(str)
      @rackspace_api_path = str
    end

    # A symbol that describes the JSON key name where the object
    # data is stored in the Peace API payload.
    def json_key_name(sym=nil)
      return @json_key_name unless sym
      @json_key_name = sym.to_s
    end

    # Find the endpoint for a Service by name and region
    def service_url
      @service_url ||= Peace.service_catalog.url_for(service_name)
    end

    # Provide the service name based on the child (calling) class
    def service_name
      @service_name ||= self.to_s.tableize.split('/')[1]
    end

    # Provide full enpoint URL for a collection of objects
    def collection_url(attrs={})
      path = (@rackspace_api_path && attrs) ? build_api_url!(attrs) : collection_name
      "#{service_url}/#{path}"
    end

    # Provide the collection name based on the child (calling) class
    def collection_name
      @collection_name ||= self.to_s.tableize.split('/').last
    end

    private

    def build_api_url!(attrs)
      path = @rackspace_api_path.dup

      attrs.each do |(k,v)|
        if arr = /{{\w+}}/.match(path)
          fragment = arr[0]
          variable = fragment[2...-2]
          value    = self.send("#{k}=", v)

          raise "Template error" unless value

          path.gsub!(fragment, value.to_s)
        end
      end

      path[0] == '/' ? path[1..-1] : path
    end
  end
end
