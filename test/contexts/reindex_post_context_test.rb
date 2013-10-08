require 'test_helper'

class ReindexPostContextTest < ActiveSupport::TestCase
  subject { ReindexPostContext }
  let(:attributes) { %w(post_list post_index popular_index) }

  include AttributesTest

  it 'adds the post to the index' do
    post = Post.new post_id: 1, message: 'foo', post_time: Time.now, username: 'bar'
    likes = {}
    context = subject.new post_list: [ post ],
                          post_index: post_index = {},
                          popular_index: popular_index = {},
                          post_likes_factory: lambda { |_| likes }
    context.call
    popular_index.keys.first.must_equal post.post_id
    post_index.keys.first.must_equal post.post_id
  end

  class PostListRoleTest < ActiveSupport::TestCase
    subject { ReindexPostContext::PostListRole }

    include DelegatorTest

    it 'yields up a post role for each' do
      post = OpenStruct.new post_id: 1
      role = subject.new([ post ])
      role.each do |post|
        post.respond_to?(:score).must_equal true
      end
    end
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { ReindexPostContext::PostRole }

    include DelegatorTest
    include PostScoreTraitTests
    include PostTimeIndexTraitTests
  end

  class PostIndexRoleTest < ActiveSupport::TestCase
    subject { ReindexPostContext::PostIndexRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { ReindexPostContext::PopularIndexRole }

    include DelegatorTest
    include IndexScoreTraitTests
  end

end
