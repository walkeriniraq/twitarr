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
    assert_operator score, :>, Time.now.to_f
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { LikePostContext::PopularIndexRole }

    include DelegatorTest
    include IndexScoreTraitTests
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { LikePostContext::PostRole }

    include DelegatorTest
    include PostScoreTraitTests

  end

end
