# test/models/post_spec.rb

require 'test_helper'
require_relative '../../app/models/post'

class PostTest < ActiveSupport::TestCase
  subject { Post.new }

  it 'starts with blank fields' do
    subject.message.must_be_nil
    subject.username.must_be_nil
    subject.post_time.must_be_nil
    subject.post_id.must_be_nil
  end

  it 'supports reading and writing the twitarr object' do
    twitarr = Object.new
    subject.twitarr = twitarr
    subject.twitarr.must_equal twitarr
  end

  it 'supports reading and writing the message' do
    message = Object.new
    subject.message = message
    subject.message.must_equal message
  end

  it 'supports reading and writing the username' do
    username = Object.new
    subject.username = username
    subject.username.must_equal username
  end

  it 'supports reading and writing the post_time' do
    post_time = Object.new
    subject.post_time = post_time
    subject.post_time.must_equal post_time
  end

  it 'supports reading and writing the post_id' do
    post_id = Object.new
    subject.post_id = post_id
    subject.post_id.must_equal post_id
  end

  it 'creates tags from @tags' do
    twitarr = mock
    tag = Object.new
    twitarr.expects(:get_tag).with('@bar').returns tag
    subject.message = 'foo @bar baz'
    subject.twitarr = twitarr
    subject.tags.must_include tag
  end

  it 'has a score' do
    time = DateTime.now
    subject.post_time = time
    subject.score(0).wont_be_nil
  end

  it 'has a higher score when the like_count goes up' do
    time = DateTime.now
    subject.post_time = time
    subject.score(1).must_be :>, subject.score(0)
  end

end
