ENV['SDK'] = "openstack"
ENV['SC_STUB'] = "true"

module Peace::Payload
  def self.included(klass)
    klass.extend ClassMethods
  end

  def payload
    {}
  end

  private

  module ClassMethods
  end
end
