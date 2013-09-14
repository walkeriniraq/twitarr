# test/models/create_post_context_test.rb

require 'test_helper'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext.new }

  it 'loads the user attribute' do
    context = CreatePostContext.new user: 'foo'
    context.user.must_equal 'foo'
  end

  it 'loads the post_text attribute' do
    context = CreatePostContext.new post_text: 'foo'
    context.post_text.must_equal 'foo'
  end

  it 'loads the tag_cloud attribute' do
    context = CreatePostContext.new tag_cloud: 'foo'
    context.tag_cloud.must_equal 'foo'
  end

end
