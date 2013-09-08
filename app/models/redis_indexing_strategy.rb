class RedisIndexingStrategy

  attr_reader :clazz

  def initialize(clazz)
    @clazz = clazz
    @db_prefix = "#{clazz.to_s}:index:"
  end

  def id_index(id)
    DbConnectionPool.instance.connection do |db|
      db.sadd("#{@db_prefix}id", id)
    end
  end

  def remove_id_index(id)
    DbConnectionPool.instance.connection do |db|
      db.srem("#{@db_prefix}id", id)
    end
  end

  def id_exist?(id)
    DbConnectionPool.instance.connection do |db|
      db.sismember("#{@db_prefix}id", id)
    end
  end

  def ids
    DbConnectionPool.instance.connection do |db|
      db.smembers "#{@db_prefix}id"
    end
  end

  def index(id, field, value)
    DbConnectionPool.instance.connection do |db|
      db.sadd "#{@db_prefix}#{field}:#{id}", value
    end
  end

  def un_index(id, field, value)
    DbConnectionPool.instance.connection do |db|
      db.srem "#{@db_prefix}#{field}:#{id}", value
    end
  end

  def indexed_values(id, field)
    DbConnectionPool.instance.connection do |db|
      db.smembers "#{@db_prefix}#{field}:#{id}"
    end
  end

  def is_indexed_value?(id, field, value)
    DbConnectionPool.instance.connection do |db|
      db.sismember "#{@db_prefix}#{field}:#{id}", value
    end
  end

end
