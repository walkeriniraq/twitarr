require_relative 'message'

class Post < Message

  def tags
    (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }
  end

  def self.find(post_ids)
    DbConnectionPool.instance.connection do |db|
      if post_ids.respond_to? :map
        post_ids.map do |id|
          data = db.get("post:#{id}")
          #TODO: figure out how to get this not to explode if data is nil or malformed
          JSON.parse data
        end
      else
        JSON.parse db.get("post:#{post_ids}")
      end
    end
  end

  def self.tagged(tag, start = 0, count = 20)
    DbConnectionPool.instance.connection do |db|
      find(db.zrange("tag:#{tag}", 0 - start - count, -1 - start).reverse)
    end
  end

  #def self.recent(start = 0, count = 20)
  #  DbConnectionPool.instance.connection do |db|
  #    data = db.lrange 'posts', start, count
  #    data.map { |x| JSON.parse x }
  #  end
  #end

  def self.delete(id)
    DbConnectionPool.instance.connection do |db|
      #post_json = db.get "post:#{id}"
      post = Post.new(find(id))
      db.del "post:#{id}"
      post.tags.each do |tag|
        db.zrem "tag:#{tag}", id
      end
      #db.lrem 'posts', 0, post_json
    end
  end

  def save
    DbConnectionPool.instance.connection do |db|
      db.set "post:#{post_id}", to_json
      #db.lpush 'posts', to_json
      tags.each do |tag|
        db.zadd "tag:#{tag}", Time.now.to_i, post_id
      end
    end
  end

end