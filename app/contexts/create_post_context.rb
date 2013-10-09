class CreatePostContext < BaseCreatePostContext

  attr :popular_index, :post_index

  def initialize(attrs = {})
    super
    @popular_index = PopularIndexRole.new(@popular_index)
    @post_index = PostIndexRole.new(@post_index)
  end

  def call
    ret = super
    popular_index.add_post @post
    post_index.add_post @post
    ret
  end

  class PopularIndexRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class PostIndexRole < SimpleDelegator
    include IndexPostTimeTrait
  end

end
