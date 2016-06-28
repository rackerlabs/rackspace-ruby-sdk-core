require 'active_support/all'
require 'active_model'

module Peace::Model

  def self.included(klass)
    klass.class_variable_set :@@alias_map, {}
    klass.class_variable_set :@@attributes, []

    klass.extend ClassMethods

    klass.class_eval do
      include ActiveModel::Validations
      include Peace::ORM
      include Peace::Association
    end
  end

  def initialize(hash={})
    send(:refresh!, hash)
  end

  def as_json(options={})
    alias_keys = self.class.alias_map.keys
    hash       = {}

    self.class.attributes.each do |(k,v)|
      if alias_keys.include?(k)
        original_name = self.class.alias_map[k].first
        hash.merge!({ "#{original_name}" => v })
      else
        hash.merge!({ "#{k}" => v })
      end
    end

    hash
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


  module ClassMethods
    def attr_accessor(*symbols)
      self.class_variable_set(:@@attributes, attributes.concat(symbols.map(&:to_s)))
      super
    end

    def attr_with_alias(original, *others)
      update_alias_map(original, *others)
      setup_attribute_aliases(original, *others)
    end

    def resource_name
      @resource_name ||= self.to_s.split('::').last.downcase
    end

    def attributes
      self.class_variable_get :@@attributes
    end

    def alias_map
      self.class_variable_get :@@alias_map
    end

    private

    def update_alias_map(original, *others)
      new_map = alias_map.merge({ "#{original}" => [*others].map(&:to_s) })
      self.class_variable_set(:@@alias_map, new_map)
    end

    def setup_attribute_aliases(original, *others)
      [*others].each do |o|
        attr_accessor original
        new_writer      = "#{o}="
        original_writer = "#{original}="
        alias_method(o, original) if method_defined? original
        alias_method(new_writer, original_writer) if method_defined? original_writer
      end
    end
  end
end
