require 'test_helper'

class CreatePostContextTest < ActiveSupport::TestCase
  subject { CreatePostContext }
  let(:attributes) { %w(user post_text tag_cloud popular_index object_store) }

  include AttributesTest

end
