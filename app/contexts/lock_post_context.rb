# class LockPostContext
#   include HashInitialize
#
#   attr :post_lock_factory, :post_store
#
#   def call(post_id)
#     raise 'Post does not exist' unless post_store.has_key?(post_id)
#     lock = post_lock_factory.call post_id
#     lock.lock do
#       post = post_store.get(post_id)
#       yield post
#     end
#   end
#
# end