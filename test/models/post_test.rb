require_relative '../test_helper'

class PostTest < ActiveSupport::TestCase
  subject { Post }
  let(:attributes) { %w(message username post_id photos) }

  include AttributesTest
  include UpdateTest

  def test_post_time_starts_at_zero
    post = Post.new
    post.post_time.must_equal 0.0
  end

  def test_post_time_converts_to_float
    date = Time.now
    post = Post.new post_time: date
    post.post_time.must_equal date.to_f
  end

  it 'adds an empty replies if not set' do
    post = Post.new
    post.replies.must_equal []
  end

end
