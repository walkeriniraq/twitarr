class RedisObjectStore

  attr_reader :db

  def initialize(redis)
    @db = redis
  end

  def get(clazz, id_or_ids)
    unless id_or_ids.is_a? Enumerable
      data = db.get("#{clazz.to_s}:#{id_or_ids}")
      return if data.nil?
      return clazz.new(JSON.parse(data))
    end
    return [] if id_or_ids.blank?
    db.mget(id_or_ids.map { |id| "#{clazz.to_s}:#{id}" }).compact.map { |x| clazz.new(JSON.parse x) }
  end

  def save(obj, id)
    db.set("#{obj.class.to_s}:#{id}", obj.to_hash(obj.class.fattrs).to_json)
  end

  def delete(clazz, id)
    db.del("#{clazz.to_s}:#{id}")
  end

end