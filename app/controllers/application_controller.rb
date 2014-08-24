class ApplicationController < BaseRedisController
  protect_from_forgery with: :exception
  # around_action :log_filter

  # def log_filter
  #   yield
  #   user = if logged_in?
  #            if is_admin?
  #              "admin/#{current_username}"
  #            else
  #              "user/#{current_username}"
  #            end
  #          else
  #            "anon"
  #          end
  #   Stats.new(redis).log_event "#{params[:controller]}/#{params[:action]}", user
  # end

  def logged_in?
    !current_username.nil?
  end

  def current_username
    session[:username]
  end

  def current_user
    @user ||= User.get current_username
  end

  def login_user(user)
    session[:username] = user.username
    session[:is_admin] = user.is_admin
  end

  def logout_user
    session.delete :username
    session.delete :is_admin
  end

  def is_admin?
    session[:is_admin]
  end

end
