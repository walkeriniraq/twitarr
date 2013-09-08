require 'bcrypt'
require_relative 'redis_storage_strategy'

class User
  include HashInitialize

  USER_KEY = 'system:users'
  USER_PREFIX = 'user:%s'
  USER_FRIENDS_PREFIX = 'user-friends:%s'

  STATUS_ACTIVE = 'active'
  STATUS_INACTIVE = 'inactive'
  STATUS_DISABLED = 'disabled'

  attr_accessor :username, :password, :is_admin, :status, :email

  #TODO: move this into a common base class
  def to_hash(*keys)
    keys.reduce({}) do |hash, key|
      hash[key] = send(key)
      hash
    end
  end

  def update(values)
    values.each do |k, v|
      if respond_to? k.to_s
        # this lets us initialize classes with attr_reader
        instance_variable_set "@#{k.to_s}", v
      else
        #TODO: replace this with some sort of logging
        puts "Invalid parameter passed to class #{self.class.to_s} initialize: #{k.to_s} - value: #{v.to_s}"
      end
    end
  end

  def self.storage=(storage)
    @storage = storage
  end

  def self.indexing=(indexing)
    @indexing = indexing
  end

  def self.storage
    @storage ||= RedisStorageStrategy.new(self)
  end

  def self.indexing
    @indexing ||= RedisIndexingStrategy.new(self)
  end

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
    self.class.storage.save username, to_hash(:username, :password, :is_admin, :status, :email)
    self.class.indexing.id_index username
  end

  def delete
    following.each { |x| unfollow x }
    self.class.indexing.remove_id_index username
    self.class.storage.delete username
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
    self.class.indexing.index username, :following, user
  end

  def unfollow(user)
    return "User #{user} does not exist in the database" unless User.exist? user
    self.class.indexing.un_index username, :following, user
  end

  def following
    self.class.indexing.indexed_values username, :following
  end

  def is_following?(user)
    self.class.indexing.is_indexed_value? username, :following, user
  end

end
