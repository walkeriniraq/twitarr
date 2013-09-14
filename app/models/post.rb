class Post
  attr_accessor :message, :post_id, :post_time, :username
end

#class Post < Message
#
#  TAG_PREFIX = 'tag:%s'
#  POST_PREFIX = 'post:%s'
#  FAVORITES_PREFIX = 'post-favorites:%s'
#  POPULAR_KEY = 'system:popular'
#
#  def tags
#    (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }.map { |x| twitarr.get_tag x }
#  end
#
#  def score(like_count)
#    post_time.to_i + like_count * 3600
#  end
#
#  def json_hash(user_liked, friends_like, other_like)
#    { message: message, username: username, post_time: post_time.to_i, post_id: post_id, liked: user_liked, liked_sentence: liked_sentence(user_liked, friends_like, other_like) }
#  end
#
#  def liked_sentence(user_liked, friends_like, other_likes)
#    likes = []
#    likes << 'You' if user_liked
#    likes += friends_like
#    other_likes = other_likes - likes.count
#    likes << "#{other_likes} people" if other_likes > 1
#    likes << '1 other person' if other_likes == 1
#    return case
#             when likes.count > 1
#               "#{likes[0..-2].join ', '} and #{likes.last} like this."
#             when likes.count > 0
#               if likes.first == 'You'
#                 'You like this.'
#               elsif other_likes > 1
#                 "#{likes.first} like this."
#               else
#                 "#{likes.first} likes this."
#               end
#           end
#  end
#
#  def save
#    storage.save post_id, { message: message, username: username, post_time: post_time.to_i, post_id: post_id }
#    twitarr.popular_posts.add_post self
#    tags.each { |tag| tag.add_post self }
#  end
#
#  #def db_save
#  #  db_pipeline do |db|
#  #    db.set POST_PREFIX % post_id, to_json
#  #    db.zadd POPULAR_KEY, db_score.call, post_id
#  #    tags.each do |tag|
#  #      db.zadd TAG_PREFIX % tag, Time.now.to_i, post_id
#  #    end
#  #  end
#  #end
#
#  #def db_score(db = nil)
#  #  db_pipeline(db) do |db|
#  #    likes = db_likes(db)
#  #    -> { score(likes.call) }
#  #  end
#  #end
#
#  #def db_likes(db = nil)
#  #  db_pipeline(db) do |db|
#  #    ret = db.scard(FAVORITES_PREFIX % post_id)
#  #    -> { ret.value }
#  #  end
#  #end
#  #
#  #def db_json_hash(user, db)
#  #  db_pipeline(db) do |db|
#  #    user_like = db.sismember FAVORITES_PREFIX % post_id, user
#  #    friends_like = db.sinter(FAVORITES_PREFIX % post_id, User::USER_FRIENDS_PREFIX % user)
#  #    other_likes = db_likes(db)
#  #    -> { json_hash(user_like.value, friends_like.value, other_likes.call) }
#  #  end
#  #end
#  #
#  #def self.all(params = {})
#  #  db_call do |db|
#  #    keys = db.keys.select { |x| x.start_with? 'post:' }.map { |x| x.gsub 'post:', '' }
#  #    return keys if params[:only_keys]
#  #    find keys
#  #  end
#  #end
#  #
#  #def self.posts_hash(posts, user)
#  #  db_pipeline do |db|
#  #    posts = posts.map { |x| x.db_json_hash user, db }
#  #  end
#  #  posts.map { |x| x.call }
#  #end
#  #
#  #def self.add_favorite(id, username)
#  #  post = find(id)
#  #  db_pipeline do |db|
#  #    db.sadd FAVORITES_PREFIX % id, username
#  #    db.zadd POPULAR_KEY, post.db_score.call, id
#  #  end
#  #end
#  #
#  #def self.find(post_ids)
#  #  return if post_ids.nil?
#  #  return [] if post_ids.empty?
#  #  db_call do |db|
#  #    if post_ids.respond_to? :map
#  #      post_ids.map do |id|
#  #        Post.new JSON.parse(db.get(POST_PREFIX % id))
#  #      end
#  #    else
#  #      Post.new JSON.parse(db.get(POST_PREFIX % post_ids))
#  #    end
#  #  end
#  #end
#  #
#  #def self.tagged(tag, start = 0, count = 20)
#  #  db_call do |db|
#  #    find db.zrevrange(TAG_PREFIX % tag.downcase, start, start + count)
#  #  end
#  #end
#  #
#  #def self.delete(id)
#  #  post = find(id)
#  #  db_pipeline do |db|
#  #    post.tags.each do |tag|
#  #      db.zrem TAG_PREFIX % tag, id
#  #    end
#  #    db.zrem POPULAR_KEY, id
#  #    db.del POST_PREFIX % id
#  #  end
#  #end
#  #
#  #def self.popular(params = {})
#  #  db_call do |db|
#  #    keys = db.zrevrange(POPULAR_KEY, params[:start] || 0, params[:stop] || 20)
#  #    return keys if params[:only_keys]
#  #    find keys
#  #  end
#  #end
#
#end