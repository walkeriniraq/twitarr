class TwitarrDb
  def self.db
    DbConnectionPool.instance.slow_connection
  end

  def self.tag_factory(redis)
    lambda { |tag| redis.tag_index tag }
  end

  def self.inbox_factory(redis)
    lambda { |user| redis.inbox_index user }
  end

  def self.feed_factory(redis)
    lambda { |user| redis.feed_index user }
  end

  def self.user(username)
    DbConnectionPool.instance.connection do |redis|
      username = username.downcase
      redis.user_store.get(username)
    end
  end

  def self.follow(from, to)
    DbConnectionPool.instance.connection do |redis|
      FriendGraph.new(redis.following, redis.followed).add(from, to)
    end
  end

  def self.unfollow(from, to)
    DbConnectionPool.instance.connection do |redis|
      FriendGraph.new(redis.following, redis.followed).remove(from, to)
    end
  end

  def self.create_seamail(from, to, subject, text)
    DbConnectionPool.instance.connection do |redis|
      mail = Seamail.new from: from, to: to, subject: subject, text: text
      context = CreateSeamailContext.new seamail: mail,
                                         from_user_sent_index: redis.sent_mail_index(mail.from),
                                         inbox_index_factory: inbox_factory(redis),
                                         seamail_store: redis.seamail_store
      context.call
    end
  end

  def self.create_post(user, post_text)
    DbConnectionPool.instance.connection do |redis|
      context = CreatePostContext.new user: user,
                                      tag_factory: tag_factory(redis),
                                      popular_index: redis.popular_posts_index,
                                      post_index: redis.post_index,
                                      post_store: redis.post_store,
                                      following_list: redis.user_followed(user).entries,
                                      feed_factory: feed_factory(redis)
      context.call post_text
    end
  end

  def self.reindex_posts
    DbConnectionPool.instance.connection do |redis|
      # TODO: fix this
      posts = redis.post_store.get(redis.keys.
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