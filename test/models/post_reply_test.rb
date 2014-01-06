require_relative '../test_helper'

class PostReplyTest < ActiveSupport::TestCase
  subject { PostReply }
  let(:attributes) { %w(message username) }

  include AttributesTest

  def test_timestamp_starts_at_zero
    reply = subject.new
    reply.timestamp.must_equal 0.0
  end

  def test_timestamp_converts_to_float
    date = Time.now
    reply = subject.new timestamp: date
    reply.timestamp.must_equal date.to_f
  end

end