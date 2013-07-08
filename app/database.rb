class Database

  def initialize(redis_connection)
    @connection = redis_connection
  end

  def write_user(user)
    # make sure that the user is in the users list - this way is probably faster than checking first
    @connection.sadd('users', user.username)
    @connection.set("user:#{user.username}", user.to_json)
  end

  def list_users
    @connection.smembers 'users'
  end

  # this is inside the server since the models shouldn't know about the redis connection
  # I've got to figure out a better way of doing this
  def get_user(username)
    data = @connection.get("user:#{username}")
    return if data.nil?
    User.new(JSON.parse(data))
  end

  def user_exist?(username)
    @connection.sismember('users', username)
  end

  def submit_post_thing(name, post)
    @connection.lpush name, post.to_json
  end

  def post_thing_list(name, start, count)
    data = @connection.lrange name, start, count
    data.map { |x| JSON.parse(x.to_s) }
  end

  def submit_post(post)
    submit_post_thing "posts", post
  end

  def post_list(start, count)
    post_thing_list "posts", start, count
  end

  def submit_announcement(post)
    submit_post_thing "announcements", post
  end

  def announcement_list(start, count)
    post_thing_list "announcements", start, count
  end

end