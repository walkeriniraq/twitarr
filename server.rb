require 'sass'
require 'redis'
require 'json'

class Server < Kul::BaseServer

  def redis_connection
    # TODO: cache this
    Redis.new(:host => 'gremlin')
  end

  def user_exist?(username)
    redis_connection.sismember('users', username)
  end

  # this is inside the server since the models shouldn't know about the redis connection
  # I've got to figure out a better way of doing this
  def get_user(username)
    data = redis_connection.get("user:#{username}")
    return if data.nil?
    User.new(JSON.parse(data))
  end

  def write_user(user)
    # make sure that the user is in the users list - this way is probably faster than checking first
    redis_connection.sadd('users', user.username)
    user.is_admin = user.is_admin == 'true' if user.is_admin.is_a? String
    redis_connection.set("user:#{user.username}", user.to_json)
  end

end