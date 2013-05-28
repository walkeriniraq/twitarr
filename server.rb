require 'redis'

class User
  include HashInitialize

  attr_accessor :username, :password, :is_admin

  def view_model
    { username: @username, is_admin: @is_admin }
  end

end

class Message
  include HashInitialize

  attr_accessor :message, :username, :post_time

  def to_json
    { message: @message, username: @username, post_time: @post_time }.to_json
  end
end

class Server < Kul::BaseServer

  def redis_connection
    Redis.new(:host => 'gremlin')
  end

  def get_user(username)
    data = redis_connection.get("user:#{username}")
    return if data.nil?
    User.new(JSON.parse(data))
  end

end