class BaseRedisController < ActionController::Base

  around_action :redis_context_filter

  def redis_context_filter
    DbConnectionPool.instance.connection do |redis|
      @redis_connection = redis
      yield
      @redis_connection = nil  # While this shouldn't be neccesary, it's best to make sure
    end
  end

  def redis
    @redis_connection
  end

  def login_required
    render json: { status: 'Not logged in.' }
  end

  def render_json(hash)
    render json: hash
  end

end