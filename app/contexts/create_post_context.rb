class CreatePostContext
  include HashInitialize

  attr :user, :tag_factory, :popular_index, :post_index, :post_store, :tag_autocomplete, :tag_scores

  def initialize(attrs = {})
    super
    @popular_index = PopularIndexRole.new(@popular_index)
    @post_index = PostIndexRole.new(@post_index)
    @user = UserRole.new(@user)
    @post_store = PostStoreRole.new(@post_store)
  end

  def call(post_text, photos = [])
    post = user.new_post(post_text, photos)
    post_store.add post
    @post = PostRole.new post
    @post.tags.each do |tag_name|
      tag = TagIndexRole.new tag_factory.call(tag_name)
      tag.add_post @post
      if tag_name[0] == '#'
        name_without_hash = tag_name[1..-1]
        tag_autocomplete.add(name_without_hash, name_without_hash, 'tag')
        tag_scores.incr(name_without_hash)
      end
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

  class UserRole < SimpleDelegator
    def new_post(message, photos)
      Post.new message: message, username: to_s, post_time: Time.now, post_id: SecureRandom.uuid, photos: photos
    end
  end

  class PostRole < SimpleDelegator
    include PostTagsTrait
    include PostTimeIndexTrait
  end

end
