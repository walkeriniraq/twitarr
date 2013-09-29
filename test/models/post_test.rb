require 'test_helper'

class PostTest < ActiveSupport::TestCase
  subject { Post }
  let(:attributes) { %w(message username post_time post_id) }

  include AttributesTest
  include UpdateTest

end
