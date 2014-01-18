require 'test_helper'

class AnnouncementTest < ActiveSupport::TestCase
  subject { Announcement }
  let(:attributes) { %w(message username post_id time_offset) }

  include AttributesTest
  include UpdateTest

  def test_post_time_starts_at_zero
    post = subject.new
    post.post_time.must_equal 0.0
  end

  def test_post_time_converts_to_float
    date = Time.now
    post = subject.new post_time: date
    post.post_time.must_equal date.to_f
  end

  def test_fattrs_include_from_base_class
    test = Announcement.fattrs
    test.must_include 'message'
  end

  it 'includes the time offset in the time_plus_offset' do
    time = Time.now
    announcement = Announcement.new(post_time: time, time_offset: 1)
    announcement.time_plus_offset.must_be :>, time.to_f
  end

  it 'translates the time offset into hours' do
    time = Time.now
    announcement = Announcement.new(post_time: time, time_offset: 1)
    announcement.time_plus_offset.must_equal time.to_f + 1.hour
  end

end
