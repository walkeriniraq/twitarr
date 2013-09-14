class CreatePostContext
  include HashInitialize

  fattr :user, :post_text, :tag_factory, :popular_index, :object_store

  class UserRole < SimpleDelegator
    def new_post(message)
      Post.new message: message, username: username, post_time: Time.now, post_id: SecureRandom.uuid
    end
  end

  class PostRole < SimpleDelegator
    def tags
      (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }
    end

    def time_hack
      post_time.to_i
    end

    def score_hack
      post_time.to_i
    end
  end

  class TagFactoryRole < SimpleDelegator
  end

  class TagRole < SimpleDelegator
    def add_post(post)
      self[post.post_id] = post.time_hack
    end
  end

  class PopularIndexRole < SimpleDelegator
    def add_post(post)
      self[post.post_id] = post.score_hack
    end
  end

  def call
    post = @user.new_post
    post.message = @post_text
    @object_store.save post
    @post = PostRole.new post
    self.post.tags.each do |tag|
      tag = TagRole.new self.tag_factory.get_tag(tag)
      tag.add_post post
    end
    @popular_index.add_post @post
  end

end

=begin
  Okay

  So state testing is good. But there's actually very little state here. Using DCI all of the functionality will be on the
  roles. We can unit test the roles I suppose. But those are going to be very dependent on the delegation functionality, which
  will make the unit testing a bear. I could use that magic hash-to-object ruby thing to make that easier I suppose.

  The context itself is just a bundle of method calls on the role objects. I mean I can stub those out but that sounds miserable.
  Basically we're talking about the inverse of the method itself, which is kind of fucking pointless.

  Alternately we can test the state of the various elements. There's kind of a subltle difference between the factories passed in that
  don't have a state and the indexes, which WOULD have state. We can test the state change on those indexes.

  Maybe that's why we keep the twitarr object around - it holds the posts. I can then test the state changes on the twitarr object.
=end
