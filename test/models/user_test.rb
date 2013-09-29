require 'test_helper'

class UserTest < ActiveSupport::TestCase
  subject { User }
  let(:attributes) { %w(username password is_admin status email) }

  include AttributesTest
  include UpdateTest

end
