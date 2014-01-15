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
    include PostScoreTrait
    include PostTimeIndexTrait
  end

  class PopularIndexRole < SimpleDelegator
    include IndexScoreTrait
  end

end