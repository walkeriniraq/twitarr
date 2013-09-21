require 'test_helper'
require 'models/post_role_tag_tests'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext }
  let(:attributes) { %w(user post_text tag_factory popular_index object_store) }

  include AttributesTest

  it 'creates a post' do
    object_store = mock
    object_store.expects(:save).with(kind_of Post)
    tag = {}
    context = CreatePostContext.new user: mock(:username => 'foo'),
                                    post_text: 'This is a test',
                                    tag_factory: lambda { |_| tag },
                                    popular_index: popular_index = {},
                                    object_store: object_store
    post = context.call
    post.username.must_equal 'foo'
    post.message.must_equal 'This is a test'
    popular_index.keys.first.must_equal post.post_id
    tag.keys.first.must_equal post.post_id
  end

  class UserRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::UserRole }

    include DelegatorTest

    it 'creates a post' do
      user = OpenStruct.new username: 'foo'
      role = subject.new(user)
      test = role.new_post 'this is a post'
      test.message.must_equal 'this is a post'
      test.username.must_equal 'foo'
      test.post_time.to_i.must_be_close_to DateTime.now.to_i, 1
      test.post_id.wont_be_nil
    end
  end

  class TagRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::TagRole }

    include DelegatorTest

    it 'adds post according to time hack' do
      post = OpenStruct.new time_hack: 4, post_id: 1
      tag = {}
      role = subject.new(tag)
      role.add_post(post)
      tag[1].must_equal post.time_hack
    end
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::PopularIndexRole }

    include DelegatorTest

    it 'adds post according to score hack' do
      post = OpenStruct.new score_hack: 4, post_id: 1
      tag = {}
      role = subject.new(tag)
      role.add_post(post)
      tag[1].must_equal post.score_hack
    end
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::PostRole }

    include DelegatorTest
    include PostRoleTagTests

    it 'time_hack is based on the post_time' do
      post = OpenStruct.new post_time: DateTime.now
      role = subject.new(post)
      role.time_hack.must_equal post.post_time.to_i
    end

    it 'score_hack is based on the post_time' do
      post = OpenStruct.new post_time: DateTime.now
      role = subject.new(post)
      role.score_hack.must_equal post.post_time.to_i
    end

  end

end
