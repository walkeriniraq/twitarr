class CreatePostContext
  include HashInitialize

  attr_accessor :user, :post_text, :tag_cloud, :popular_index, :object_store

  #class UserRole < SimpleDelegator
  #  def new_post(message)
  #    Post.new message: message, username: username, post_time: Time.now, post_id: SecureRandom.uuid
  #  end
  #end

  # user role - #new_post
  # post role - #tags
  # tag_cloud role - #add_post
  # popular_index role - #add_post

  #def call
  #  post = @user.new_post
  #  post.message = @post_text
  #  @object_store.save post
  #  @post = PostRole.new post
  #  @tag_cloud.add_post @post, @post.tags
  #  @popular_index.add_post @post
  #end

end

  # BASICS
  # create post

  # create the post / save the post
  # add the post to popular posts
  # add the post to tags

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
