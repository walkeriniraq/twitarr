class BaseCreatePostContext
  include HashInitialize

  attr :user, :post_text, :tag_factory, :object_store

  def initialize(attrs = {})
    super
    @user = UserRole.new(@user)
  end

  def call
    post = user.new_post(post_text)
    object_store.save post, post.post_id
    @post = PostRole.new post
    @post.tags.each do |tag|
      tag = TagRole.new tag_factory.call(tag)
      tag.add_post @post
    end
    post
  end

  class UserRole < SimpleDelegator
    def new_post(message)
      Post.new message: message, username: to_s, post_time: Time.now.to_f, post_id: SecureRandom.uuid
    end
  end

  class PostRole < SimpleDelegator
    include PostTagsTrait
    include PostTimeIndexTrait
  end

  class TagRole < SimpleDelegator
    include IndexTimeTrait
  end

end