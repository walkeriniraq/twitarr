require 'bcrypt'

class User
  include HashInitialize

  USER_KEY = 'system:users'
  USER_PREFIX = 'user:%s'
  USER_FRIENDS_PREFIX = 'user-friends:%s'

  attr_accessor :username, :password, :is_admin, :status, :email

  def empty_password
    password.nil? || password.empty?
  end

  def set_password(unencrypted_password)
    @password = BCrypt::Password.create unencrypted_password
  end

  #TODO: move this into a common base class
  def to_hash(keys)
    keys.each_with_object({}) do |key, map|
      map[key] = send(key)
    end
  end

  def gui_hash
    { username: username, is_admin: is_admin, friends: friends }
  end

  def to_json(params = {})
    to_hash([:username, :password, :is_admin, :status, :email]).to_json(params)
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

  def is_friend?(friend)
    DbConnectionPool.instance.connection do |db|
      db.sismember(USER_FRIENDS_PREFIX % username, friend)
    end
  end

  def self.add_friend(username, friend)
    return "User #{friend} does not exist in the database" unless User.exist? friend
    DbConnectionPool.instance.connection do |db|
      db.sadd(USER_FRIENDS_PREFIX % username, friend)
    end
  end

  def self.remove_friend(username, friend)
    return "User #{friend} does not exist in the database" unless User.exist? friend
    DbConnectionPool.instance.connection do |db|
      db.srem(USER_FRIENDS_PREFIX % username, friend)
    end
  end

  def friends
    DbConnectionPool.instance.connection do |db|
      db.smembers USER_FRIENDS_PREFIX % username
    end
  end

  def save
    DbConnectionPool.instance.connection do |db|
      db.sadd(USER_KEY, username)
      db.set(USER_PREFIX % username, to_json)
    end
  end

  def self.list_usernames
    DbConnectionPool.instance.connection do |db|
      db.smembers USER_KEY
    end
  end

  def self.exist?(username)
    DbConnectionPool.instance.connection do |db|
      db.sismember(USER_KEY, username)
    end
  end

  def self.get(username)
    DbConnectionPool.instance.connection do |db|
      data = db.get(USER_PREFIX % username)
      return if data.nil?
      User.new(JSON.parse(data))
    end
  end

end