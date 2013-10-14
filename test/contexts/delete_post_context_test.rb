require 'test_helper'
require 'traits/post_role_trait_tests'

class DeletePostContextTest < ActiveSupport::TestCase
  subject { DeletePostContext }
  let(:attributes) { %w(post tag_factory popular_index posts_store) }

  include AttributesTest

  it 'creates a post' do
    post = OpenStruct.new username: 'foo', message: 'This is my test', post_id: 3
    tag = { 3 => 123 }
    context = DeletePostContext.new post: post,
                                    tag_factory: lambda { |_| tag },
                                    popular_index: popular_index = { 3 => 123 },
                                    posts_store: posts_store = { 3 => 123 }
    context.call
    popular_index.must_be_empty
    tag.must_be_empty
    posts_store.must_be_empty
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { DeletePostContext::PostRole }
    include DelegatorTest
    include PostRoleTraitTests
  end

  class PopularIndexRoleTest < ActiveSupport::TestCase
    subject { DeletePostContext::PopularIndexRole }
    include DelegatorTest

    it 'deletes the post id from the index' do
      post = OpenStruct.new score_hack: 4, post_id: 1
      index = { 1 => 4 }
      role = subject.new(index)
      role.delete_post(post)
      index.must_be_empty
    end
  end

  class PostIndexRoleTest < ActiveSupport::TestCase
    subject { DeletePostContext::PostIndexRole }
    include DelegatorTest

    it 'deletes the post id from the index' do
      post = OpenStruct.new score_hack: 4, post_id: 1
      index = { 1 => 4 }
      role = subject.new(index)
      role.delete_post(post)
      index.must_be_empty
    end
  end

  class TagRoleTest < ActiveSupport::TestCase
    subject { DeletePostContext::TagRole }
    include DelegatorTest

    it 'deletes the post id from the index' do
      post = OpenStruct.new post_id: 1
      tag = { 1 => 4 }
      role = subject.new(tag)
      role.delete_post(post)
      tag.must_be_empty
    end
  end

end
