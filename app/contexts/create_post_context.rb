class CreatePostContext
  include HashInitialize

  attr :user, :tag_factory, :popular_index, :post_index, :post_store, :following_list, :feed_factory

  def initialize(attrs = {})
    super
    @popular_index = PopularIndexRole.new(@popular_index)
    @post_index = PostIndexRole.new(@post_index)
    @user = UserRole.new(@user)
    @post_store = PostStoreRole.new(@post_store)
    @following_list ||= []
  end

  def call(post_text)
    post = user.new_post(post_text)
    post_store.add post
    @post = PostRole.new post
    @post.tags.each do |tag|
      tag = TagIndexRole.new tag_factory.call(tag)
      tag.add_post @post
    end
    @following_list.each do |follower|
      feed = FeedRole.new feed_factory.call(follower)
      feed.add_post @post
    end
    popular_index.add_post @post
    post_index.add_post @post
    post
  end

  class PostStoreRole < SimpleDelegator
    def add(post)
      save(post, post.post_id)
    end
  end

  class PopularIndexRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class PostIndexRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class TagIndexRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class FeedRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class UserRole < SimpleDelegator
    def new_post(message)
      Post.new message: message, username: to_s, post_time: Time.now, post_id: SecureRandom.uuid
    end
  end

  class PostRole < SimpleDelegator
    include PostTagsTrait
    include PostTimeIndexTrait
  end

end
