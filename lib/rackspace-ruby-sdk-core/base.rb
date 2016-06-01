module Peace

  SERVICE_NAME_MAP = {
    'auto_scale'    => 'autoscale',
    'backup'        => 'cloudBackup',
    'big_datum'     => 'cloudBigData',
    'block_storage' => 'cloudBlockStorage',
    'cdn'           => 'cloudFilesCDN',
    'compute'       => 'cloudServersOpenStack',
    'database'      => 'cloudDatabases',
    'dns'           => 'cloudDNS',
    'feed'          => 'cloudFeeds',
    'image'         => 'cloudImages',
    # 'keep'          => 'cloudKeep',
    'load_balancer' => 'cloudLoadBalancers',
    'metrics'       => 'cloudMetrics',
    'monitoring'    => 'cloudMonitoring',
    'networking'    => 'cloudNetworks',
    'orchestration' => 'cloudOrchestration',
    'queue'         => 'cloudQueues',
    'storage'       => 'cloudFiles'
  }

  SERVICE_KLASSES = {
    'auto_scale'    => 'Rackspace::AutoScale',
    'backup'        => 'Rackspace::Backup',
    'big_data'      => 'Rackspace::BigDatum',
    'block_storage' => 'Rackspace::BlockStorage',
    'cdn'           => 'Rackspace::CDN',
    'compute'       => 'Rackspace::Compute',
    'database'      => 'Rackspace::Database',
    'dns'           => 'Rackspace::DNS',
    'feeds'         => 'Rackspace::Feed',
    'image'         => 'Rackspace::Image',
    # 'keep'          => 'Rackspace::Keep',
    'load_balancer' => 'Rackspace::LoadBalancer',
    'metrics'       => 'Rackspace::Metrics',
    'monitoring'    => 'Rackspace::Monitoring',
    'networking'    => 'Rackspace::Networking',
    'orchestration' => 'Rackspace::Orchestration',
    'queue'         => 'Rackspace::Queue',
    'storage'       => 'Rackspace::Storage'
  }

  @@auth_token      = nil
  @@service_catalog = nil
  @@tenant_id       = nil
  @@logger          = nil

  class << self
    def auth_token
      @@auth_token
    end

    def tenant_id
      @@tenant_id
    end

    def service_catalog(host=:rackspace)
      @@service_catalog ||= Peace::ServiceCatalog.load!(host)
    end

    def auth_token=(token)
      @@auth_token = token
    end

    def tenant_id=(id)
      @@tenant_id = id
    end

    def service_catalog=(catalog)
      @@service_catalog = catalog
    end

    def logger
      @@logger ||= Peace::Logger.logger
    end
  end
end

Dir[File.expand_path "lib/rackspace-ruby-sdk-core/modules/*.rb"].each{ |f| require_relative f }
Dir[File.expand_path "lib/rackspace-ruby-sdk-core/*.rb"].each{ |f| require_relative f }
