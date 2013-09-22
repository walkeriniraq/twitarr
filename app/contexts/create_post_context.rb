class CreatePostContext
  include HashInitialize

  fattr :user, :post_text, :tag_factory, :popular_index, :object_store

  def initialize(attrs = {})
    super
    @user = UserRole.new(@user)
    @popular_index = PopularIndexRole.new(@popular_index)
  end

  def call
    post = user.new_post(post_text)
    self.object_store.save post
    post_role = PostRole.new post
    post_role.tags.each do |tag|
      tag = TagRole.new self.tag_factory.call(tag)
      tag.add_post post_role
    end
    self.popular_index.add_post post_role
    post
  end

  class UserRole < SimpleDelegator
    def new_post(message)
      Post.new message: message, username: username, post_time: Time.now, post_id: SecureRandom.uuid
    end
  end

  class PostRole < SimpleDelegator
    include PostTagsTrait

    def time_index
      post_time.to_f
    end

    def score
      post_time.to_f
    end
  end

  class TagRole < SimpleDelegator
    def add_post(post)
      self[post.post_id] = post.time_index
    end
  end

  class PopularIndexRole < SimpleDelegator
    def add_post(post)
      self[post.post_id] = post.score
    end
  end

end
