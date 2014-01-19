require_relative '../test_helper'

class PostReplyContextTest < ActiveSupport::TestCase
  subject { PostReplyContext }
  let(:attributes) { %w(post tag_factory tag_autocomplete post_store popular_index tag_scores) }

  include AttributesTest

  it 'returns the reply' do
    post = Post.new(post_id: 'foo')
    context = subject.new post: post,
                          tag_factory: lambda { |_| {} },
                          post_store: FakePostsStore.new,
                          popular_index: {}
    ret = context.call 'steve', 'text'
    ret.must_equal post.replies.last
  end

  it 'adds the comment to the post comments' do
    post = Post.new(post_id: 'foo')
    context = subject.new post: post,
                          tag_factory: lambda { |_| {} },
                          post_store: FakePostsStore.new,
                          popular_index: {}
    context.call 'steve', 'text'
    post.replies.count.must_equal 1
  end

  it 'saves the post to the post_store' do
    store = FakePostsStore.new
    post = Post.new(post_id: 'foo')
    context = subject.new post: post,
                          tag_factory: lambda { |_| {} },
                          post_store: store,
                          popular_index: {}
    context.call 'steve', 'text'
    store.store.values.first.must_equal post
  end

  it 'saves the post with the correct id' do
    store = FakePostsStore.new
    post = Post.new(post_id: 'foo')
    context = subject.new post: post,
                          tag_factory: lambda { |_| {} },
                          post_store: store,
                          popular_index: {}
    context.call 'steve', 'text'
    store.store['foo'].must_equal post
  end

  it 'updates the post_score in the popular index' do
    post = Post.new(post_id: 'foo')
    context = subject.new post: post,
                          tag_factory: lambda { |_| {} },
                          post_store: FakePostsStore.new,
                          popular_index: popular_index = { }
    context.call 'steve', 'text'
    popular_index.keys.first.must_equal post.post_id
  end

  it 'adds the post_id to the tag index' do
    tag = {}
    post = Post.new(post_id: 'foo')
    context = subject.new post: post,
                          tag_factory: lambda { |_| tag },
                          post_store: FakePostsStore.new,
                          popular_index: {},
                          tag_scores: {},
                          tag_autocomplete: mock(:add => true)
    context.call 'steve', 'This is a #test'
    tag.keys.first.must_equal post.post_id
  end

  it 'adds the score for the tag' do
    tag_index = {}
    context = subject.new post: Post.new(post_id: 'foo'),
                          tag_factory: lambda { |_| tag_index },
                          post_store: FakePostsStore.new,
                          popular_index: {},
                          tag_scores: tag_scores = {},
                          tag_autocomplete: mock(:add => true)
    context.call 'steve', 'This is a #test'
    tag_scores['test'].must_equal tag_index.size
  end

  it 'adds the tag to the autocomplete index' do
    auto = mock()
    auto.expects(:add).with('test', 'test', 'tag').once
    context = subject.new post: Post.new(post_id: 'foo'),
                          tag_factory: lambda { |_| {} },
                          post_store: FakePostsStore.new,
                          popular_index: {},
                          tag_scores: {},
                          tag_autocomplete: auto
    context.call 'steve', 'This is a #test'
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { PostReplyContext::PopularIndexRole }

    it 'updates the score of a post' do
      post = Post.new post_id: 'foo'
      test = { 'foo' => 1 }
      role = subject.new test
      role.update_score post
      test['foo'].must_equal 7201
    end
  end

  class TagRoleTest < ActiveSupport::TestCase
    subject { PostReplyContext::TagIndexRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class PostReplyRoleTest < ActiveSupport::TestCase
    subject { PostReplyContext::PostReplyRole }

    include DelegatorTest
    include PostRoleTraitTests
    include PostTimeIndexTrait
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { PostReplyContext::PostRole }

    include DelegatorTest

    it 'sets the reply username' do
      post = Post.new
      role = subject.new post
      role.add_reply 'steve', 'text'
      post.replies.first.username.must_equal 'steve'
    end

    it 'sets the reply text' do
      post = Post.new
      role = subject.new post
      role.add_reply 'steve', 'text'
      post.replies.first.message.must_equal 'text'
    end

    it 'sets the reply timestamp' do
      post = Post.new
      role = subject.new post
      role.add_reply 'steve', 'text'
      post.replies.first.timestamp.must_be_close_to Time.now.to_f
    end

  end

end