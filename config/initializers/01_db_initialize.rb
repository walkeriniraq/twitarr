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

  def popular_posts_index(opts = {})
    sorted_set 'System:popular_posts_index', opts
  end

  def post_index(opts = {})
    sorted_set 'System:post_index', opts
  end

  def user_friends_set(username)
    redis_set "System:user_friends:#{username}"
  end

  def user_set
    redis_set 'System:users'
  end

  def announcements_index
    sorted_set 'System:accouncements_index'
  end

  def reindex_posts
    posts = object_store.get(Post, keys.select { |x| x.start_with? 'Post:' }.map { |x| x.sub('Post:', '')})
    context = ReindexPostContext.new post_list: posts,
                                     post_index: post_index,
                                     popular_index: popular_posts_index,
                                     post_likes_factory: lambda { |post| post_favorites_set post.post_id }
    context.call
  end

end