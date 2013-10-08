require 'test_helper'
require 'traits/post_role_trait_tests'

class CreateAnnouncementContextTest < ActiveSupport::TestCase
  subject { CreateAnnouncementContext }
  let(:attributes) { %w(user post_text tag_factory announcement_index object_store) }

  include AttributesTest

  it 'creates a post' do
    object_store = mock
    object_store.expects(:save).with(kind_of(Post), kind_of(String))
    tag = {}
    context = CreateAnnouncementContext.new user: 'foo',
                                    post_text: 'This is a test',
                                    tag_factory: lambda { |_| tag },
                                    announcement_index: announcement_index = {},
                                    object_store: object_store
    post = context.call
    post.username.must_equal 'foo'
    post.message.must_equal 'This is a test'
    announcement_index.keys.first.must_equal post.post_id
    tag.keys.first.must_equal post.post_id
  end

  class UserRoleTest < ActiveSupport::TestCase
    subject { CreateAnnouncementContext::UserRole }

    include DelegatorTest

    it 'creates a post' do
      user = 'foo'
      role = subject.new(user)
      test = role.new_post 'this is a post'
      test.message.must_equal 'this is a post'
      test.username.must_equal 'foo'
      test.post_time.to_i.must_be_close_to Time.now.to_i, 1
      test.post_id.wont_be_nil
    end
  end

  class TagRoleTest < ActiveSupport::TestCase
    subject { CreateAnnouncementContext::TagRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class AnnouncementIndexRoleTest < ActiveSupport::TestCase
    subject { CreateAnnouncementContext::AnnouncementIndexRole }

    include DelegatorTest
    include IndexTimeTraitTests
  end

  class PostRoleTest < ActiveSupport::TestCase
    subject { CreateAnnouncementContext::PostRole }

    include DelegatorTest
    include PostRoleTraitTests
    include PostTimeIndexTrait

  end

end
