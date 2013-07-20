require 'bcrypt'
require 'json'

class User
  include HashInitialize

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

  def to_json
    to_hash([:username, :password, :is_admin, :status, :email]).to_json
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

  def save
    DbConnectionPool.instance.connection do |db|
      db.sadd('users', username)
      db.set("user:#{username}", to_json)
    end
  end

  def self.list_usernames
    DbConnectionPool.instance.connection do |db|
      db.smembers 'users'
    end
  end

  def self.exist?(username)
    DbConnectionPool.instance.connection do |db|
      db.sismember('users', username)
    end
  end

  def self.get(username)
    DbConnectionPool.instance.connection do |db|
      data = db.get("user:#{username}")
      return if data.nil?
      User.new(JSON.parse(data))
    end
  end

end