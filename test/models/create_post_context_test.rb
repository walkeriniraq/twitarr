require 'test_helper'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext }
  let(:attributes) { %w(user post_text tag_cloud popular_index object_store) }

  include AttributesTest

  class UserRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::UserRole }

    include DelegatorTest

    it 'creates a post' do
      user = OpenStruct.new username: 'foo'
      role = subject.new(user)
      test = role.new_post 'this is a post'
      test.message.must_equal 'this is a post'
      test.username.must_equal 'foo'
      test.post_time.to_i.must_be_close_to DateTime.now.to_i, 1
      test.post_id.wont_be_nil
    end
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { CreatePostContext::PostRole }

    include DelegatorTest

    it 'includes the post username in the tags' do
      post = OpenStruct.new username: 'foo', message: ''
      role = subject.new(post)
      role.tags.must_include '@foo'
    end

    it 'includes @usernames included in the message' do
      post = OpenStruct.new username: 'foo', message: 'foo @bar baz'
      role = subject.new(post)
      role.tags.must_include '@bar'
    end

    it 'includes #tags included in the message' do
      post = OpenStruct.new username: 'foo', message: 'foo #bar baz'
      role = subject.new(post)
      role.tags.must_include '#bar'
    end

    it 'lowercases tags' do
      post = OpenStruct.new username: 'foo', message: 'foo #BAR baz'
      role = subject.new(post)
      role.tags.must_include '#bar'
      role.tags.wont_include '#BAR'
    end

    it 'lowercases usernames' do
      post = OpenStruct.new username: 'foo', message: 'foo @BAR baz'
      role = subject.new(post)
      role.tags.must_include '@bar'
      role.tags.wont_include '@BAR'
    end

  end

end
