# class PostReplyContext
#   include HashInitialize
#
#   attr :post, :tag_factory, :tag_autocomplete, :post_store, :popular_index, :tag_scores
#
#   def initialize(attrs = {})
#     super
#     @post = PostRole.new(post)
#     @popular_index = PopularIndexRole.new popular_index
#   end
#
#   def call(username, text)
#     reply = post.add_reply(username, text)
#     post_store.save(post.__getobj__, post.post_id)
#     reply.tags.each do |tag_name|
#       tag = TagIndexRole.new tag_factory.call(tag_name)
#       tag.add_post reply
#       if tag_name[0] == '#'
#         name_without_hash = tag_name[1..-1]
#         tag_autocomplete.add(name_without_hash, name_without_hash, 'tag')
#         tag_scores[name_without_hash] = tag.size
#       end
#     end
#     popular_index.update_score post
#     reply
#   end
#
#   class PopularIndexRole < SimpleDelegator
#     def update_score(post)
#       self[post.post_id] = (self[post.post_id] || 0) + 7200
#     end
#   end
#
#   class TagIndexRole < SimpleDelegator
#     include IndexPostTimeTrait
#   end
#
#   class PostReplyRole < SimpleDelegator
#     include PostTagsTrait
#
#     def initialize(reply, post = nil)
#       super(reply)
#       @post = post
#     end
#
#     def post_id
#       @post.post_id
#     end
#
#     def time_index
#       timestamp.to_f
#     end
#   end
#
#   class PostRole < SimpleDelegator
#     def add_reply(username, text)
#       reply = PostReply.new(username: username, message: text, timestamp: Time.now)
#       replies << reply
#       PostReplyRole.new reply, self
#     end
#   end
#
# end