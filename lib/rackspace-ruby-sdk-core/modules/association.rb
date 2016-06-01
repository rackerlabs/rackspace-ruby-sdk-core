module Peace::Association
  def self.included(klass)
    klass.extend ClassMethods
  end

  def available_resources
    self.class.available_resources
  end

  module ClassMethods
    @@has_many   = {}
    @@belongs_to = {}

    def belongs_to(sym)
      self.class_attribute "#{sym}_id"

      @@belongs_to[self.resource_name.to_sym] ||= []
      @@belongs_to[self.resource_name.to_sym] << sym

      define_method sym, lambda {
        modpath     = self.class.to_s.split('::')
        modpath[-1] = sym.to_s.classify # Inject :sym classname
        klass       = modpath.join('::').constantize

        klass.find(self.send("#{sym}_id"))
      }
    end

    def has_many(sym)
      @@has_many[self.resource_name.to_sym] ||= []
      @@has_many[self.resource_name.to_sym] << sym

      define_method sym, lambda {
        modpath     = self.class.to_s.split('::')
        modpath[-1] = sym.to_s.classify # Inject :sym classname
        klass       = modpath.join('::').constantize
        mapping     = { "#{self.resource_name}_id".to_sym => :id}

        hash = mapping.inject({}) do |map, (k,v)|
          map.merge({"#{k}": self.send(v)})
        end

        klass.all(hash)
      }
    end

    def available_resources
      hm = @@has_many[self.resource_name.to_sym] ||= []
      bt = @@belongs_to[self.resource_name.to_sym] ||= []
      hm + bt
    end
  end
end
