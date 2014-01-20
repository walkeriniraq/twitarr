require_relative '../test_helper'

class UserTest < ActiveSupport::TestCase
  subject { User }
  let(:attributes) { %w(username password is_admin status email last_login) }

  include AttributesTest
  include UpdateTest

  it 'allows characters in usernames' do
    User.valid_username?('steve').must_equal true
  end

  it 'allows numbers in usernames' do
    User.valid_username?('steven12').must_equal true
  end

  it 'allows underscores in usernames' do
    User.valid_username?('steven_12').must_equal true
  end

  it 'allows dashes in usernames' do
    User.valid_username?('steven-12').must_equal true
  end

  it 'allows ampersands in usernames' do
    User.valid_username?('steven&mary').must_equal true
  end

  it 'disallows short usernames' do
    User.valid_username?('st').must_equal false
  end

  it 'disallows spaces in usernames' do
    User.valid_username?('stan evanston').must_equal false
  end

  it 'disallows periods in usernames' do
    User.valid_username?('stan.evanston').must_equal false
  end

  it 'allows characters in display name' do
    User.valid_display_name?('steve').must_equal true
  end

  it 'allows numbers in display name' do
    User.valid_display_name?('steven12').must_equal true
  end

  it 'allows underscores in display_names' do
    User.valid_display_name?('steven_12').must_equal true
  end

  it 'allows dashes in display_names' do
    User.valid_display_name?('steven-12').must_equal true
  end

  it 'allows ampersands in display_names' do
    User.valid_display_name?('steven&mary').must_equal true
  end

  it 'disallows short display_names' do
    User.valid_display_name?('st').must_equal false
  end

  it 'allows spaces in display names' do
    User.valid_display_name?('stan evanston').must_equal true
  end

  it 'allows periods in display names' do
    User.valid_display_name?('mr. evanston').must_equal true
  end

  it 'disallows % characters in display names' do
    User.valid_display_name?('mr% evanston').must_equal false
  end

  it 'only allows 40 characters for display_name' do
    User.valid_display_name?('01234567890123456789012345678901234567890').must_equal false
  end

  it 'updates the last_login timestamp' do
    user = User.new
    user.last_login.must_equal nil
    user.update_last_login
    user.last_login.must_be_close_to Time.now.to_f
  end

  it 'returns user from update_last_login' do
    user = User.new
    test = user.update_last_login
    test.must_equal user
  end

end
