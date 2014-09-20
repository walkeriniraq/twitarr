class API::V2::BaseController < ActionController::Base

  # def valid_api_key?
  #   return false unless params[:api_key]
  #   redis.redis_set('System:api_keys').member? params[:api_key]
  # end

  def current_user
    @current_username
  end

  def logged_in?
    !@current_username.nil?
  end

end