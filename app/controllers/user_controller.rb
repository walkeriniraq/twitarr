require 'bcrypt'
require 'json'

class UserController < ApplicationController

  def login
    user = User.get(params[:username])
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'User account has been disabled.' if user.status != 'active' || user.password.nil?
    return render_json status: 'Invalid username or password.' if BCrypt::Password.new(user.password) != params[:password]
    login_user(user)
    render_json status: 'ok', user: user.gui_hash
  end

  def follow
    return render_json status: 'User does not exist.' unless User.exist?(params[:username])
    User.add_friend(current_username, params[:username])
    render_json status: 'ok'
  end

  def unfollow
    return render_json status: 'User does not exist.' unless User.exist?(params[:username])
    User.remove_friend(current_username, params[:username])
    render_json status: 'ok'
  end

  def username
    if logged_in?
      user = User.get(current_username)
      return render_json status: 'User does not exist.' if user.nil?
      return render_json status: 'User account has been disabled.' if user.status != 'active' || user.password.nil?
      return render_json status: 'ok', user: user.gui_hash
    end
    render_json status: 'logout'
  end

  def new
    user = User.new
    user.username = params[:username].downcase
    user.email = params[:email]
    user.status = 'inactive'
    user.is_admin = false
    return render_json status: 'Username must be at least six characters.' if user.username.nil? || user.username.length < 6
    return render_json status: 'Username cannot contain spaces or the following characters: %#:' unless User.valid_username? params[:username]
    return render_json status: 'Username already exists.' if User.exist? user.username
    return render_json status: 'Email address is not valid.' if (user.email =~ /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) != 0
    return render_json status: 'Password must be at least six characters long.' if params[:password].length < 6
    return render_json status: 'Passwords do not match.' if params[:password] != params[:password2]
    user.set_password params[:password]
    user.save
    render_json status: 'ok'
  end

  def logout
    logout_user
    render_json status: 'ok'
  end

  def change_password
    return login_required unless logged_in?
    return render_json status: 'Password must be at least six characters long.' if params[:new_password].length < 6
    return render_json status: 'New passwords do not match.' if params[:new_password] != params[:new_password2]
    user = User.get(username)
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'Invalid username or password.' if BCrypt::Password.new(user.password) != params[:old_password]
    user.password = BCrypt::Password.create params[:new_password]
    user.save
  end

end