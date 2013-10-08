class ApplicationController < BaseRedisController
  protect_from_forgery with: :exception

  def logged_in?
    !current_username.nil?
  end

  def current_username
    session[:username]
  end

  def current_user
    @user ||= object_store.get(User, current_username)
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

end
