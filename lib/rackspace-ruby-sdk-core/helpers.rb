class Peace::Helpers

  def self.wait_for(obj, state='ACTIVE')
    obj.reload

    while obj.state != state
      sleep 1 if VCR.current_cassette.recording?
      obj.reload
    end

    obj
  end

  def self.payload_builder(namespace, hash)
    data            = {}
    data[namespace] = {}

    hash.each do |(k,v)|
      if v.present?
        data[namespace].merge!({ "#{k}": v })
      end
    end

    data
  end

end
