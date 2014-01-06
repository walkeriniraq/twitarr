require_relative '../test_helper'

class LockPostContextTest < ActiveSupport::TestCase
  subject { LockPostContext }
  let(:attributes) { %w(post_lock_factory post_store) }

  include AttributesTest

  class FakeLock
    def lock
      yield
    end
  end

  it 'locks the post' do
    store = mock(:has_key? => true)
    context = subject.new post_store: store,
                          post_lock_factory: lambda { |_| mock(:lock => nil) }
    context.call('foo') { |_| nil }
  end

  it 'gets the post from the store' do
    post = Post.new
    store = mock(:has_key? => true)
    store.expects(:get).with('foo').returns(post)
    context = subject.new post_store: store,
                          post_lock_factory: lambda { |_| FakeLock.new }
    context.call('foo') { |_| nil }
  end

  it 'yields the post to the block' do
    post = Post.new
    store = mock(:has_key? => true, :get => post)
    context = subject.new post_store: store,
                          post_lock_factory: lambda { |_| FakeLock.new }
    block_post = nil
    context.call('foo') do |post|
      block_post = post
    end
    block_post.must_equal post
  end

  it 'throws if the post does not exist' do
    store = mock(:has_key? => false)
    context = subject.new post_store: store,
                          post_lock_factory: lambda { |_| FakeLock.new }
    assert_raises(RuntimeError) { context.call('foo') { |_| nil } }
  end

end