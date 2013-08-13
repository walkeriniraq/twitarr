class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def logged_in?
    puts "CURRENT USERNAME: #{current_username}"
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
