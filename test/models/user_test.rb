require 'test_helper'
require 'base_model_test'

class UserTest < BaseModelTest
  subject { User }
  let(:attributes) { %w(username password is_admin status email) }

  it 'starts with blank fields' do
    attributes_start_blank_test attributes
  end

  it 'reads and writes attributes' do
    attributes_start_blank_test attributes
  end

end
