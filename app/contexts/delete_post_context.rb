class DeletePostContext
  include HashInitialize

  fattr :post, :tag_factory, :popular_index, :object_store

  def initialize(attrs = {})
    super
    @post = PostRole.new @post
    @popular_index = PopularIndexRole.new @popular_index
  end

  class PostRole < SimpleDelegator
    include PostTagsTrait
  end

  class PopularIndexRole < SimpleDelegator
    def delete_post(post)
      delete(post.post_id)
    end
  end

  class TagRole < SimpleDelegator
    def delete_post(post)
      delete(post.post_id)
    end
  end

  def call
    self.popular_index.delete_post post
    self.post.tags.each do |tag|
      tag = TagRole.new self.tag_factory.call(tag)
      tag.delete_post post
    end
    self.object_store.delete post
  end

end
