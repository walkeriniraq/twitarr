require_relative '../test_helper'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext }
  let(:attributes) { %w(user tag_factory popular_index post_index post_store tag_autocomplete tag_scores photo_store) }

  include AttributesTest

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

  it 'adds the post to the post_store' do
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
                          post_store: FakePostsStore.new,
                          tag_scores: mock(:incr => true),
                          tag_autocomplete: mock(:add => true)
    post = context.call 'This is a #test'
    tag.keys.first.must_equal post.post_id
  end

  it 'increases the score for the tag' do
    scores = mock()
    scores.expects(:incr).with('test').once
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: {},
                          post_store: FakePostsStore.new,
                          tag_autocomplete: mock(:add => true),
                          tag_scores: scores
    context.call 'This is a #test'
  end

  it 'adds the tag to the autocomplete index' do
    auto = mock()
    auto.expects(:add).with('test', 'test', 'tag').once
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: {},
                          post_store: FakePostsStore.new,
                          tag_scores: mock(:incr => true),
                          tag_autocomplete: auto
    context.call 'This is a #test'
  end

  it 'sets the post_id in the photos' do
    photo_store = mock
    photo = PhotoMetadata.new
    photo_store.expects(:get).with('foo.jpg').once.returns(photo)
    photo_store.expects(:save).with(photo, 'foo.jpg').once
    context = subject.new user: 'foo',
                          tag_factory: lambda { |_| {} },
                          popular_index: {},
                          post_index: {},
                          post_store: FakePostsStore.new,
                          photo_store: photo_store
    post = context.call 'This is a test', ['foo.jpg']
    post.post_id.must_equal photo.post_id
  end

  class UserRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::UserRole }

    include DelegatorTest

    it 'creates a post' do
      user = 'foo'
      role = subject.new(user)
      test = role.new_post 'this is a post', []
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
