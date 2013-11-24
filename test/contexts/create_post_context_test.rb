require 'test_helper'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext }
  let(:attributes) { %w(user tag_factory popular_index post_index post_store feed_factory) }

  include AttributesTest

  class FakePostsStore
    attr :store

    def initialize
      @store = {}
    end

    def save(post, id)
      @store[id] = post
    end
  end

  it 'defaults the following_list to empty array' do
    test = subject.new
    test.following_list.must_equal []
  end

  it 'has accessor for following_list' do
    test = subject.new
    test.following_list = 'foo'
    test.following_list.must_equal 'foo'
  end

  it 'creates and returns a post' do
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: {},
                          post_store: FakePostsStore.new
    post = context.call 'This is a test'
    post.username.must_equal 'foo'
    post.message.must_equal 'This is a test'
  end

  it 'adds the json string to the post_store' do
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: {},
                          post_store: post_store = FakePostsStore.new
    post = context.call 'This is a test'
    store = post_store.store
    store.count.must_equal 1
    store.keys.first.must_be_kind_of String
    store.values.first.must_be_kind_of Post
    store.values.first.must_equal post
  end

  it 'adds the post_id to the popular index' do
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: popular_index = {},
                          post_index: {},
                          post_store: FakePostsStore.new
    post = context.call 'This is a test'
    popular_index.keys.first.must_equal post.post_id
  end

  it 'adds the post_id to the post_index' do
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: post_index = {},
                          post_store: FakePostsStore.new
    post = context.call 'This is a test'
    post_index.keys.first.must_equal post.post_id
  end

  it 'adds the post_id to the tag index' do
    tag = {}
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| tag },
                          popular_index: {},
                          post_index: {},
                          post_store: FakePostsStore.new
    post = context.call 'This is a #test'
    tag.keys.first.must_equal post.post_id
  end

  it 'adds the post_id to the feed index' do
    feed = {}
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: {},
                          post_store: FakePostsStore.new,
                          following_list: ['steve'],
                          feed_factory: lambda { |_| feed }
    post = context.call 'This is a test'
    feed.keys.first.must_equal post.post_id
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
    subject { CreatePostContext::TagIndexRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class FeedRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::FeedRole }

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
