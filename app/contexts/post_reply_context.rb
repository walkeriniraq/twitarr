class PostReplyContext
  include HashInitialize

  attr :post, :tag_factory, :tag_autocomplete, :post_store, :popular_index

  def initialize(attrs = {})
    super
    @post = PostRole.new(post)
    @popular_index = PopularIndexRole.new popular_index
  end

  def call(username, text)
    reply = post.add_reply(username, text)
    post_store.save(post.__getobj__, post.post_id)
    reply.tags.each do |tag_name|
      tag = TagIndexRole.new tag_factory.call(tag_name)
      tag.add_post reply
      tag_autocomplete.add(tag_name[1..-1], tag_name[1..-1], 'tag') if tag_name[0] == '#'
    end
    popular_index.update_score post
    post
  end

  class PopularIndexRole < SimpleDelegator
    def update_score(post)
      self[post.post_id] = (self[post.post_id] || 0) + 7200
    end
  end

  class TagIndexRole < SimpleDelegator
    include IndexPostTimeTrait
  end

  class PostReplyRole < SimpleDelegator
    include PostTagsTrait

    def initialize(reply, post = nil)
      super(reply)
      @post = post
    end

    def post_id
      @post.post_id
    end

    def time_index
      timestamp.to_f
    end
  end

  class PostRole < SimpleDelegator
    def add_reply(username, text)
      reply = PostReply.new(username: username, message: text, timestamp: Time.now)
      replies << reply
      PostReplyRole.new reply, self
    end
  end

end