class Announcement < Message

  def self.recent(start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      data = db.lrange 'announcements', start, count
      data.map { |x| JSON.parse x }
    end
  end

  def save
    DbConnectionPool.instance.connection do |db|
      db.set "announcement:#{post_id}", to_json
      db.lpush 'announcements', to_json
    end
  end

end