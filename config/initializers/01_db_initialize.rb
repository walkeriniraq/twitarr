require Rails.root + 'lib/db_connection_pool'

DbConnectionPool.instance.configure(Rails.application.config.db)

# this is a horrible hack due to the way that redis objects are configured
Redis::Objects.redis = Redis.new Rails.application.config.db

class Redis
  def object_store
    RedisObjectStore.new(self)
  end

  def list(name, opts = {})
    Redis::List.new(name, self, opts)
  end

  def hash(name, opts = {})
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
    redis_set "System:post_likes:#{post_id}"
  end

  def tag_index(tag)
    sorted_set "System:tag_index:#{tag}"
  end

  def inbox_index(username)
    sorted_set "System:inbox_index:#{username}"
  end

  def sent_mail_index(username)
    sorted_set "System:sent_index:#{username}"
  end

  def popular_posts_index(opts = {})
    sorted_set 'System:popular_posts_index', opts
  end

  def post_index(opts = {})
    sorted_set 'System:post_index', opts
  end

  def post_store
    RedisHashObjectStore.new hash('System:posts_store'), Post
  end

  def following
    NamedSetCache.new lambda { |name| redis_set "System:user_following:#{name}" }
  end

  def followed
    NamedSetCache.new lambda { |name| redis_set "System:user_followed:#{name}" }
  end

  def user_set
    redis_set 'System:users'
  end

  def announcements_list
    RedisObjectList.new list('System:announcements_list'), Announcement
  end

end