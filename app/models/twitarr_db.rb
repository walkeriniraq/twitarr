class TwitarrDb
  def self.redis
    DbConnectionPool.instance.slow_connection
  end

  def self.tag_factory(redis)
    lambda { |tag| redis.tag_index tag }
  end

  def self.create_post(user, post_text)
    DbConnectionPool.instance.connection do |redis|
      context = CreatePostContext.new user: user,
                                      tag_factory: tag_factory(redis),
                                      popular_index: redis.popular_posts_index,
                                      post_index: redis.post_index,
                                      post_store: redis.post_store
      context.call post_text
    end
  end

  def self.reindex_posts
    DbConnectionPool.instance.connection do |redis|
      posts = redis.object_store.get(Post, redis.keys.
          select { |x| x.start_with? 'Post:' }.
          map { |x| x.sub('Post:', '') })
      context = ReindexPostContext.new post_list: posts,
                                       post_index: redis.post_index,
                                       popular_index: redis.popular_posts_index,
                                       post_likes_factory: lambda { |post| redis.post_favorites_set post.post_id }
      context.call
    end
  end

end