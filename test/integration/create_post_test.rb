require 'test_helper'

class CreatePostTest < ActionDispatch::IntegrationTest
  it 'creates a post' do
    user = create_or_find_user 'test'
    context = CreatePostContext.new user: user, post_text: 'This is a test',
  end
end
