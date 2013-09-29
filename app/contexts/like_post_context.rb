class LikePostContext
  include HashInitialize

  attr :post, :post_likes, :username, :popular_index

  def initialize(attrs = {})
    super
    @post = PostRole.new(@post)
    @popular_index = PopularIndexRole.new(@popular_index)
  end

  def call
    post_likes << username
    popular_index.add_post post, post_likes.size
    post.score(post_likes.size)
  end

  class PostRole < SimpleDelegator
    def score(likes_count)
      post_time.to_f + likes_count * 3600
    end
  end

  class PopularIndexRole < SimpleDelegator
    def add_post(post, likes_count)
      self[post.post_id] = post.score(likes_count)
    end
  end

end