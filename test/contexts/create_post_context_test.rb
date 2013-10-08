require 'test_helper'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext }
  let(:attributes) { %w(user post_text tag_factory popular_index post_index object_store) }

  include AttributesTest

  it 'creates a post' do
    object_store = mock
    object_store.expects(:save).with(kind_of(Post), kind_of(String))
    tag = {}
    context = CreatePostContext.new user: 'foo',
                                    post_text: 'This is a test',
                                    tag_factory: lambda { |_| tag },
                                    popular_index: popular_index = {},
                                    post_index: post_index = {},
                                    object_store: object_store
    post = context.call
    post.username.must_equal 'foo'
    post.message.must_equal 'This is a test'
    popular_index.keys.first.must_equal post.post_id
    post_index.keys.first.must_equal post.post_id
    tag.keys.first.must_equal post.post_id
  end

  class UserRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::UserRole }

    include DelegatorTest

    it 'creates a post' do
      user = 'foo'
      role = subject.new(user)
      test = role.new_post 'this is a post'
      test.message.must_equal 'this is a post'
      test.username.must_equal 'foo'
      test.post_time.to_i.must_be_close_to Time.now.to_i, 1
      test.post_id.wont_be_nil
    end
  end

  class TagRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::TagRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::PopularIndexRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class PostIndexRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::PostIndexRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::PostRole }

    include DelegatorTest
    include PostRoleTraitTests
    include PostTimeIndexTraitTests

  end

end
