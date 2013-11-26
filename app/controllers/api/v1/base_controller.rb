class API::V1::BaseController < BaseRedisController

  #before_filter :authenticate_user

  def authenticate_user
    #return render_json( status: 'API Key required for access' ) unless valid_api_key?
    authenticate_or_request_with_http_basic do |username, password|
      return false unless username && password
      @user = redis.user_store.get(username)
      @user.correct_password(password)
    end
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