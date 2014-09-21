require 'bcrypt'
require 'json'

class UserController < ApplicationController

  DEFAULT_PASSWORD = 'seamonkey'
  ACTIVE_STATUS = 'active'

  layout 'login'

  def login
    user = User.get params[:username]
    if user.nil?
      @error = 'User does not exist.'
      render :login_page
    elsif user.status != ACTIVE_STATUS || user.empty_password?
      @error = 'User account has been disabled.'
      render :login_page
    elsif !user.correct_password(params[:password])
      @error = 'Invalid username or password.'
      render :login_page
    else
      login_user(user)
      user.update_last_login.save
      redirect_to :root
    end
  end

  def login_page
  end

  def username
    if logged_in?
      if current_user.nil?
        # this is a special case - need to log the current user out
        logout_user
        return render_json status: 'User does not exist.'
      end
      return render_json status: 'User account has been disabled.' if current_user.status != ACTIVE_STATUS || current_user.password.nil?
      current_user.update_last_login.save
      puts "Successful login for user: #{current_username}"
      return render_json status: 'ok',
                         user: current_user.decorate.gui_hash,
                         need_password_change: current_user.correct_password(DEFAULT_PASSWORD),
                         is_read_only: Twitarr::Application.config.read_only
    end
    render_json status: 'logout'
  end

  def logout
    logout_user
    render_json status: 'ok'
  end

  def autocomplete
    render_json names: User.where(username: /^#{params[:string]}/).map(:username)
  end

end
