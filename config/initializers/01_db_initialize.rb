require Rails.root + 'lib/db_connection_pool'

DbConnectionPool.instance.configure(Rails.application.config.db)

class Redis
  #def object_store
  #  RedisObjectStore.new(self)
  #end

  def value(name, opts = {})
    Redis::Value.new(name, self, opts)
  end

  def list(name, opts = {})
    Redis::List.new(name, self, opts)
  end

  def redis_hash(name, opts = {})
    Redis::HashKey.new(name, self, opts)
  end

  def redis_set(name, opts = {})
    Redis::Set.new(name, self, opts)
  end

  def sorted_set(name, opts = {})
    Redis::SortedSet.new(name, self, opts)
  end

  ###
  # Custom initializers for twitarr
  ###

  def post_favorites_set(post_id)
    redis_set "post:post_likes:#{post_id}"
  end

  def tag_index(tag)
    sorted_set "post:tag_index:#{tag}"
  end

  def inbox_index(username)
    sorted_set "user:inbox_index:#{username}"
  end

  def archive_mail_index(username)
    sorted_set "user:archive_index:#{username}"
  end

  def sent_mail_index(username)
    sorted_set "user:sent_index:#{username}"
  end

  def feed_index(username)
    sorted_set feed_name(username)
  end

  def announcements
    RedisObjectSet.new sorted_set('system:announcements'), Announcement
  end

  def feed_name(username)
    "user:feed_index:#{username}"
  end

  def popular_posts_index(opts = {})
    sorted_set 'post:popular_posts_index', opts
  end

  def post_index(opts = {})
    sorted_set 'post:post_index', opts
  end

  def post_store
    RedisHashObjectStore.new redis_hash('post:store'), Post
  end

  def user_store
    RedisHashObjectStore.new redis_hash('user:store'), User
  end

  def seamail_store
    RedisHashObjectStore.new redis_hash('seamail:store'), Seamail
  end

  def following
    NamedSetCache.new lambda { |name| user_following(name) }
  end

  def user_following(name)
    redis_set "user:following:#{name}"
  end

  def followed
    NamedSetCache.new lambda { |name| user_followed(name) }
  end

  def user_followed(name)
    redis_set "user:followed:#{name}"
  end

  def user_set
    redis_set 'system:users'
  end

  def friend_graph
    FriendGraph.new(following, followed)
  end

  def user_auto
    RedisAutocomplete.new sorted_set('system:autocomplete:user')
  end

end

class Redis
  class SortedSet
    def unionstore(name, sets, opts = {})
      redis.zunionstore(name, keys_from_objects([self] + sets), opts)
    end
  end
end