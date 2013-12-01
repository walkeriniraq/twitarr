require_relative '../test_helper'

class EntryListContextTest < ActiveSupport::TestCase
  subject { EntryListContext }
  let(:attributes) { %w(announcement_list posts_index post_store) }

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
    context = EntryListContext.new announcement_list: [],
                                   posts_index: [],
                                   post_store: TestObjectStore.new
    list = context.call
    list.must_be_kind_of Enumerable
  end

  it 'includes posts' do
    context = EntryListContext.new announcement_list: [],
                                   posts_index: [1],
                                   post_store: TestObjectStore.new(
                                       1 => Post.new(post_id: 1, post_time: Time.now)
                                   )
    list = context.call
    list.count.must_equal 1
    list.first.must_be_kind_of Entry
    list.first.entry_id.must_equal 1
  end

  it 'includes announcements' do
    context = EntryListContext.new announcement_list: [Announcement.new(post_id: 'a1', post_time: Time.now)],
                                   posts_index: [],
                                   post_store: TestObjectStore.new
    list = context.call
    list.count.must_equal 1
    list.first.must_be_kind_of Entry
    list.first.entry_id.must_equal 'a1'
  end

  it 'lists recent posts after old announcements' do
    context = EntryListContext.new announcement_list: [Announcement.new(post_id: 'a1', post_time: Time.now - 360)],
                                   posts_index: ['p1'],
                                   post_store: TestObjectStore.new(
                                       'p1' => Post.new(post_id: 'p1', post_time: Time.now)
                                   )
    list = context.call
    list.count.must_equal 2
    list.first.entry_id.must_equal 'p1'
    list.second.entry_id.must_equal 'a1'
  end

  it 'moves announcements with time_offset ahead of posts' do
    context = EntryListContext.new announcement_list: [Announcement.new(post_id: 'a1', post_time: Time.now - 60, time_offset: 360)],
                                   posts_index: ['p1'],
                                   post_store: TestObjectStore.new(
                                       'p1' => Post.new(post_id: 'p1', post_time: Time.now)
                                   )
    list = context.call
    list.count.must_equal 2
    list.first.entry_id.must_equal 'a1'
    list.second.entry_id.must_equal 'p1'
  end

  it 'accepts missing announcements' do
    context = EntryListContext.new posts_index: ['p1'],
                                   post_store: TestObjectStore.new(
                                       'p1' => Post.new(post_id: 'p1', post_time: Time.now)
                                   )
    list = context.call
    list.count.must_equal 1
    list.first.entry_id.must_equal 'p1'
  end

  class AnnouncementRoleTest < ActiveSupport::TestCase
    subject { EntryListContext::AnnouncementRole }
    include DelegatorTest

    it 'includes the time offset in the time_plus_offset' do
      time = Time.now
      announcement = Announcement.new(post_time: time, time_offset: 360)
      role = subject.new(announcement)
      role.time_plus_offset.must_be :>, time.to_f
    end

    it 'puts the post_id as the entry_id' do
      post = Announcement.new(post_id: 123)
      role = subject.new(post)
      role.to_entry.entry_id.must_equal 123
    end

    it 'moves the message' do
      post = Announcement.new(message: 'foo')
      role = subject.new(post)
      role.to_entry.message.must_equal 'foo'
    end

    it 'sets the type to be announcement' do
      post = Announcement.new(message: 'foo')
      role = subject.new(post)
      role.to_entry.type.must_equal :announcement
    end

    it 'does not include the offset in the time' do
      post = Announcement.new(post_time: 1234, time_offset: 100)
      role = subject.new(post)
      role.to_entry.time.must_equal 1234
    end

    it 'copies username to from' do
      post = Post.new(username: 'steve')
      role = subject.new(post)
      role.to_entry.from.must_equal 'steve'
    end

  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { EntryListContext::PostRole }
    include DelegatorTest

    it 'puts the post_id as the entry_id' do
      announcement = Post.new(post_id: 123)
      role = subject.new(announcement)
      role.to_entry.entry_id.must_equal 123
    end

    it 'moves the message' do
      post = Post.new(message: 'foo')
      role = subject.new(post)
      role.to_entry.message.must_equal 'foo'
    end

    it 'sets the type to be post' do
      post = Post.new(message: 'foo')
      role = subject.new(post)
      role.to_entry.type.must_equal :post
    end

    it 'copies over the time' do
      post = Post.new(post_time: 1234)
      role = subject.new(post)
      role.to_entry.time.must_equal 1234
    end

    it 'copies username to from' do
      post = Post.new(username: 'steve')
      role = subject.new(post)
      role.to_entry.from.must_equal 'steve'
    end

  end

end
