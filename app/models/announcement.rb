class Announcement < Message

  ANNOUNCEMENT_KEY = 'system:announcements'
  ANNOUNCEMENT_PREFIX = 'announcement:%s'

  def self.recent(start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      data = db.lrange ANNOUNCEMENT_KEY, start, start + count
      data.map { |x| JSON.parse x }
    end
  end

  def self.delete(id)
    DbConnectionPool.instance.connection do |db|
      val = db.get ANNOUNCEMENT_PREFIX % id
      db.del ANNOUNCEMENT_PREFIX % id
      db.lrem ANNOUNCEMENT_KEY, 0, val
    end
  end

  def save
    DbConnectionPool.instance.connection do |db|
      db.set ANNOUNCEMENT_PREFIX % post_id, to_json
      db.lpush ANNOUNCEMENT_KEY, to_json
    end
  end

end