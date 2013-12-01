require_relative '../test_helper'

class CreateAnnouncementContextTest < ActiveSupport::TestCase
  subject { CreateAnnouncementContext }
  let(:attributes) { %w(set) }

  include AttributesTest

  class MockSet
    attr_accessor :saved_data
    def initialize
      @saved_data = {}
    end
    def save(obj, key)
      @saved_data[key] = obj
    end
  end

  it 'adds an announcement to the list' do
    context = subject.new set: set = MockSet.new
    context.call('foo', 'this is a test', 0)
    set.saved_data.count.must_equal 1
    set.saved_data.values.first.must_be_kind_of Announcement
  end

  it 'sets the time of the announcement' do
    context = subject.new set: set = MockSet.new
    context.call('foo', 'this is a test', 0)
    set.saved_data.values.first.post_time.wont_be_nil
  end

  it 'adds an announcement with the time as the key' do
    context = subject.new set: set = MockSet.new
    context.call('foo', 'this is a test', 0)
    set.saved_data.keys.first.must_equal set.saved_data.values.first.post_time
  end

end
