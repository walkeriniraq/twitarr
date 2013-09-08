class RedisStorageStrategy

  attr_reader :clazz

  def initialize(clazz)
    @clazz = clazz
    @db_prefix = "#{clazz.to_s}:"
  end

  def save(id, properties)
    DbConnectionPool.instance.connection do |db|
      db.set(@db_prefix + id, properties.to_json)
    end
  end

  def get(id)
    DbConnectionPool.instance.connection do |db|
      data = db.get(@db_prefix + id)
      return if data.nil?
      @clazz.new(JSON.parse(data))
    end
  end

  def delete(id)
    DbConnectionPool.instance.connection do |db|
      db.del(@db_prefix + id)
    end
  end

end