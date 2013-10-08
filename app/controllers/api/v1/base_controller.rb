class API::V1::BaseController < BaseRedisController

  before_filter :authenticate_user

  def authenticate_user
    return render_json( status: 'API Key required for access' ) unless valid_api_key?
    return render_json( status: 'Username and password required for API access' ) unless params[:username] && params[:password]
    @user = object_store.get(User, params[:username])
    return render_json( status: 'Incorrect password' ) unless @user.correct_password(params[:password])
  end

  def valid_api_key?
    return false unless params[:api_key]
    redis.redis_set('System:api_keys').member? params[:api_key]
  end

  def current_user
    @current_username
  end

  def logged_in?
    !@current_username.nil?
  end

end