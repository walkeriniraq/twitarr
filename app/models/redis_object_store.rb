class RedisObjectStore

  attr_reader :connection_pool

  def initialize(connection_pool = nil)
    @connection_pool = connection_pool || DbConnectionPool.instance
  end

  def get(clazz, id_or_ids)
    self.connection_pool.connection do |db|
      unless id_or_ids.is_a? Enumerable
        data = db.get("#{clazz.to_s}:#{id_or_ids}")
        return if data.nil?
        return clazz.new(JSON.parse(data))
      end
      db.mget(id_or_ids.map { |id| "#{clazz.to_s}:#{id}" }).compact.map { |x| clazz.new(JSON.parse x) }
    end
  end

  def save(obj, id)
    self.connection_pool.connection do |db|
      db.set("#{obj.class.to_s}:#{id}", obj.to_hash(obj.class.fattrs).to_json)
    end
  end

  def delete(clazz, id)
    self.connection_pool.connection do |db|
      db.del("#{clazz.to_s}:#{id}")
    end
  end

end