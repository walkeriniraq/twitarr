require_relative '..\test_helper'

class PostsListContextTest < ActiveSupport::TestCase
  subject { PostsListContext }
  let(:attributes) { %w(announcement_store posts_index object_store) }

  include AttributesTest

  class TestObjectStore
    def initialize(hash = {})
      @hash = hash
    end

    def get(id)
      @hash[id]
    end

  end

  it 'returns a list' do
    context = PostsListContext.new announcement_store: [],
                                   posts_index: [],
                                   object_store: TestObjectStore.new
    list = context.call
    list.must_be_kind_of Enumerable
  end

  it 'lists posts' do
    context = PostsListContext.new announcement_store: [],
                                   posts_index: [1],
                                   object_store: TestObjectStore.new({ 1 => { post_id: 1, post_time: Time.now } })
    list = context.call
    list.count.must_equal 1
    list.first.must_be_kind_of Post
    list.first.post_id.must_equal 1
  end

  it 'lists announcements' do
    context = PostsListContext.new announcement_store: [ Announcement.new(post_id: 'a1', post_time: Time.now) ],
                                   posts_index: [],
                                   object_store: TestObjectStore.new
    list = context.call
    list.count.must_equal 1
    list.first.must_be_kind_of Announcement
    list.first.post_id.must_equal 'a1'
  end

  it 'lists recent posts after old announcements' do
    context = PostsListContext.new announcement_store: [ Announcement.new(post_id: 'a1', post_time: Time.now - 360) ],
                                   posts_index: [ 'p1' ],
                                   object_store: TestObjectStore.new( 'p1' => { post_id: 'p1', post_time: Time.now } )
    list = context.call
    list.count.must_equal 2
    list.first.must_be_kind_of Post
    list.second.must_be_kind_of Announcement
  end

  it 'moves announcements with time_offset ahead of posts' do
    context = PostsListContext.new announcement_store: [ Announcement.new(post_id: 'a1', post_time: Time.now - 60, time_offset: 360) ],
                                   posts_index: [ 'p1' ],
                                   object_store: TestObjectStore.new( 'p1' => { post_id: 'p1', post_time: Time.now } )
    list = context.call
    list.count.must_equal 2
    list.first.must_be_kind_of Announcement
    list.second.must_be_kind_of Post
  end

  class AnnouncementRoleTest < ActiveSupport::TestCase
    subject { PostsListContext::AnnouncementRole }
    include DelegatorTest

    it 'includes the time offset in the post_time' do
      time = Time.now
      announcement = Announcement.new( post_time: time, time_offset: 360 )
      role = subject.new(announcement)
      role.post_time.must_be :>, time.to_f
    end

  end

end
