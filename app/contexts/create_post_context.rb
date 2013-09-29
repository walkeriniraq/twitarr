class CreatePostContext < BaseCreatePostContext

  attr :popular_index

  def initialize(attrs = {})
    super
    @popular_index = PopularIndexRole.new(@popular_index)
  end

  def call
    ret = super
    popular_index.add_post @post
    ret
  end

  class PopularIndexRole < SimpleDelegator
    def add_post(post)
      self[post.post_id] = post.time_index
    end
  end

end
