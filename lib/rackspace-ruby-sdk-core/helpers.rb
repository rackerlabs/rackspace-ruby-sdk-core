class Peace::Helpers

  def self.save_and_wait_for(obj)
    obj.save
    obj.reload

    while obj.state != "ACTIVE"
      sleep 10
      print '.'
      obj.reload
    end

    obj
  end

end
