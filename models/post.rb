class Post < Message

  def tags
    # TODO: reverse these?
    ["@#{username}"] + message.scan(/[@#]\w+/)
  end

  def self.find(post_ids)
    DbConnectionPool.instance.connection do |db|
      [*post_ids].map { |id| JSON.parse db.hget('posts', id) }
    end
  end

  def self.tagged(tag, start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      find(db.zrange("tag:#{tag}", 0 - start - count, -1 - start).reverse)
    end
  end

  def self.recent(start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      data = db.lrange 'posts', start, count
      data.map { |x| JSON.parse x }
    end
  end

  def save
    DbConnectionPool.instance.connection do |db|
      db.set "post:#{post_id}", to_json
      db.lpush 'posts', to_json
      tags.each do |tag|
        db.zadd "tag:#{tag}", Time.now.to_i, post_id
      end
    end
  end

end