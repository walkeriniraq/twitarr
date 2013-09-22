class RedisObjectStore
  def get(clazz, id)
    data = db.get("#{clazz.to_s}:#{id}")
    clazz.new(data)
  end

  def save(obj)
    db.set("#{obj.class.to_s}:#{id}", obj.to_hash(obj.class.fattrs))
  end

  def delete(clazz, id)
    db.del("#{clazz.to_s}:#{id}")
  end

end