class Announcement < Post
  attr :time_offset

  self.singleton_class.send(:alias_method, :old_fattrs, :fattrs)

  def self.fattrs
    old_fattrs + superclass.fattrs
  end

  def time_plus_offset
    post_time + (time_offset || 0) * 360
  end

end