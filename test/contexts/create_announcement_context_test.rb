require_relative '..\test_helper'

class CreateAnnouncementContextTest < ActiveSupport::TestCase
  subject { CreateAnnouncementContext }
  let(:attributes) { %w(list) }

  include AttributesTest

  it 'adds an announcement to the list' do
    context = subject.new list: list = []
    context.call('foo', 'this is a test', 0)
    list.count.must_equal 1
    list.first.must_be_kind_of Announcement
  end

  it 'adds an announcement to the beginning of the list' do
    context = subject.new list: list = ['foo']
    context.call('foo', 'this is a test', 0)
    list.count.must_equal 2
    list.first.must_be_kind_of Announcement
  end

end
