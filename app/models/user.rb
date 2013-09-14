require 'bcrypt'

class User < BaseModel

  USER_KEY = 'system:users'
  USER_PREFIX = 'user:%s'
  USER_FRIENDS_PREFIX = 'user-friends:%s'

  STATUS_ACTIVE = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUS_DISABLED = 'disabled'

  attr_accessor :username, :password, :is_admin, :status, :email

  def username
    @username.downcase
  end

  def empty_password
    password.nil? || password.empty?
  end

  def set_password(unencrypted_password)
    @password = BCrypt::Password.create unencrypted_password
  end

  def gui_hash
    to_hash :username, :is_admin, :following
  end

  def self.valid_username?(username)
    [':', ' ', '#', '%', '@'].all? { |x| !username.include? x }
  end

  def save
    storage.save username, to_hash(:username, :password, :is_admin, :status, :email)
    indexing.id_index username
  end

  def delete
    following.each { |x| unfollow x }
    indexing.remove_id_index username
    storage.delete username
  end

  def self.get(username)
    storage.get(username)
  end

  def self.exist?(username)
    indexing.id_exist?(username.downcase)
  end

  def self.list_usernames
    indexing.ids
  end

  def follow_user(user)
    return "User #{user} does not exist in the database" unless User.exist? user
    indexing.index username, :following, user
  end

  def unfollow(user)
    return "User #{user} does not exist in the database" unless User.exist? user
    indexing.un_index username, :following, user
  end

  def following
    indexing.indexed_values username, :following
  end

  def is_following?(user)
    indexing.is_indexed_value? username, :following, user
  end

end
