module Peace::Metadata

  def get_metadata
    Peace::Request.get("#{self.url}/metadata")
  end

  def set_metadata(hash)
    url = "#{self.url}/metadata"
    Peace::Request.put(url, { metadata: hash })
    self.reload
    self.metadata
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
