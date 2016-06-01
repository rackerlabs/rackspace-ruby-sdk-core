require 'active_support/all'
require 'active_model'

class Peace::Model
  include ActiveModel::Validations
  include Peace::ORM
  include Peace::Association

  def self.resource_name
    @resource_name ||= self.to_s.split('::').last.downcase
  end

  def initialize(hash={})
    send(:refresh!, hash)
  end

  def to_json
    { "#{resource_name}": self }.to_json
  end

  def resource_name
    self.class.to_s.split('::').last.downcase
  end


  private

  def refresh!(hash)
    keys      = hash.keys
    is_nested = (keys.count == 1 && keys.first == resource_name)
    hash      = is_nested ? hash.first[1] : hash

    # TODO: Why does this key exist? How does it get inserted? Why? BUG
    hash.delete("resource_name")

    hash.each do |(k,v)|
      begin
        self.send("#{k}=", v)
      rescue Exception => e
        Peace.logger.error "Peace::Model#refresh failed: #{e}"
      end
    end

    self
  end
end
