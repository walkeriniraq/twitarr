class ReindexPostContext
  include HashInitialize

  attr :post_list, :post_index, :popular_index, :post_likes_factory

  def initialize(attrs = {})
    super
    @post_list = PostListRole.new @post_list
    @post_index = PostIndexRole.new @post_index
    @popular_index = PopularIndexRole.new @popular_index
  end

  def call
    post_list.each do |post|
      post_likes = post_likes_factory.call(post)
      popular_index.add_post post, post_likes.size
      post_index.add_post post
    end
  end

  class PostListRole < SimpleDelegator
    def each
      __getobj__.each { |x| yield PostRole.new x }
    end
  end

  class PostRole < SimpleDelegator
    include PostScoreTrait
    include PostTimeIndexTrait
  end

  class PostIndexRole < SimpleDelegator
    include IndexTimeTrait
  end

  class PopularIndexRole < SimpleDelegator
    include IndexScoreTrait
  end

end