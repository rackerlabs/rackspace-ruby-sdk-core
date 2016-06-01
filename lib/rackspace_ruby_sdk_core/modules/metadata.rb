module Peace::Metadata

  def self.included(klass)
    klass.extend ClassMethods
  end

  def get_metadata; end
  def set_metadata; end
  def delete_metadata; end

  def get_metadata_item; end
  def set_metadata_item; end
  def delete_metadata_item; end

  module ClassMethods
  end
end

# # Metadata
# block_storage/snapshot
# compute/server
# keep/secret
# storage/account
# storage/container
# storage/object
# queue/queue
# orchestration/resource
#
# # MetadataItem
# compute/image
