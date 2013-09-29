require 'test_helper'

class LikePostContextTest < ActiveSupport::TestCase
  subject { LikePostContext }
  let(:attributes) { %w(post post_likes username popular_index) }

  include AttributesTest

  it 'adds likes to a post' do
    post = Post.new post_id: 1, message: 'foo', post_time: Time.now, username: 'bar'
    context = LikePostContext.new post: post,
                                  post_likes: post_likes = Set.new,
                                  username: 'steve',
                                  popular_index: popular_index = {}
    score = context.call
    popular_index.keys.first.must_equal post.post_id
    post_likes.must_include 'steve'
    assert_operator score, :>, Time.now.to_i
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { LikePostContext::PopularIndexRole }

    include DelegatorTest

    it 'adds post according to score hack' do
      post = OpenStruct.new post_id: 1
      post.expects(:score).with(4).returns(24)
      index = {}
      role = subject.new(index)
      role.add_post(post, 4)
      index[1].must_equal 24
    end
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { LikePostContext::PostRole }

    include DelegatorTest

    it 'score is based on the post_time' do
      post = OpenStruct.new post_time: Time.now
      role = subject.new(post)
      role.score(0).must_equal post.post_time.to_f
    end

    it 'has a higher score than an earlier post with the same likes' do
      older_post = OpenStruct.new post_time: Time.now
      sleep(0.1)
      post = OpenStruct.new post_time: Time.now
      role = subject.new(post)
      older_role = subject.new(older_post)
      assert_operator role.score(0), :>, older_role.score(0)
    end

    it 'has a lower score than an earlier post with more likes' do
      older_post = OpenStruct.new post_time: Time.now
      sleep(0.1)
      post = OpenStruct.new post_time: Time.now
      role = subject.new(post)
      older_role = subject.new(older_post)
      assert_operator role.score(0), :<, older_role.score(1)
    end

  end

end
