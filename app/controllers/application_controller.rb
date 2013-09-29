class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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

  def object_store
    @object_store ||= redis.object_store
  end

  def tag_factory(redis)
    lambda { |tag| redis.tag_index tag }
  end

  def logged_in?
    !current_username.nil?
  end

  def current_username
    session[:username]
  end

  def login_user(user)
    session[:username] = user.username
    session[:is_admin] = user.is_admin
  end

  def logout_user
    session[:username] = nil
    session[:is_admin] = false
  end

  def is_admin?
    session[:is_admin]
  end

  def login_required
    render json: { status: 'Not logged in.' }
  end

  def render_json(hash)
    render json: hash
  end

end
