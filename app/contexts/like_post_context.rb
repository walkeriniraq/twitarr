class LikePostContext
  include HashInitialize

  attr :post, :post_likes, :username, :popular_index, :user_feed

  def initialize(attrs = {})
    super
    @post = PostRole.new(@post)
    @popular_index = PopularIndexRole.new(@popular_index)
    @user_feed = FeedRole.new(@user_feed) if @user_feed
  end

  def call
    post_likes << username
    popular_index.add_post post, post_likes.size
    user_feed.add_post @post if user_feed
    post.score(post_likes.size)
  end

  class FeedRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class PostRole < SimpleDelegator
    include PostScoreTrait
    include PostTimeIndexTrait
  end

  class PopularIndexRole < SimpleDelegator
    include IndexScoreTrait
  end

end