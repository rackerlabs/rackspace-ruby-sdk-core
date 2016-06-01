module Peace
end

Dir[File.expand_path "lib/rackspace_ruby_sdk_core/modules/*.rb"].each{ |f| require_relative f }
Dir[File.expand_path "lib/rackspace_ruby_sdk_core/*.rb"].each{ |f| require_relative f }
