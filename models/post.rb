require_relative 'message'

class Post < Message

  TAG_PREFIX = 'tag:%s'
  POST_PREFIX = 'post:%s'
  FAVORITES_PREFIX = 'post-favorites:%s'
  POPULAR_KEY = 'system:popular'

  def tags
    (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }
  end

  def score
    DbConnectionPool.instance.connection do |db|
      post_time.to_i / 60 + db.scard(FAVORITES_PREFIX % post_id)
    end
  end

  def ui_json_hash
    DbConnectionPool.instance.connection do |db|
      { message: message, username: username, post_time: post_time.to_i, post_id: post_id, likes: db.smembers(FAVORITES_PREFIX % post_id) }
    end
  end

  def save
    DbConnectionPool.instance.connection do |db|
      db.set POST_PREFIX % post_id, to_json
      db.zadd POPULAR_KEY, score, post_id
      tags.each do |tag|
        db.zadd TAG_PREFIX % tag, Time.now.to_i, post_id
      end
    end
  end

  def self.add_favorite(id, username)
    DbConnectionPool.instance.connection do |db|
      post = find(id)
      db.sadd FAVORITES_PREFIX % id, username
      db.zadd POPULAR_KEY, post.score, id
    end
  end

  def self.find(post_ids)
    return if post_ids.nil?
    return [] if post_ids.empty?
    DbConnectionPool.instance.connection do |db|
      if post_ids.respond_to? :map
        post_ids.map do |id|
          Post.new JSON.parse(db.get(POST_PREFIX % id))
        end
      else
        Post.new JSON.parse(db.get(POST_PREFIX % post_ids))
      end
    end
  end

  def self.tagged(tag, start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      find db.zrevrange(TAG_PREFIX % tag, start, start + count)
    end
  end

  def self.delete(id)
    DbConnectionPool.instance.connection do |db|
      post = find(id)
      post.tags.each do |tag|
        db.zrem TAG_PREFIX % tag, id
      end
      db.zrem POPULAR_KEY, id
      db.del POST_PREFIX % id
    end
  end

  def self.popular(start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      find db.zrevrange(POPULAR_KEY, start, start + count)
    end
  end

end