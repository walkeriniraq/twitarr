require 'bcrypt'
require 'json'

class UserController < ApplicationController
  skip_around_action :redis_context_filter, only: [:logout]

  def login
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'User account has been disabled.' if user.status != 'active' || user.password.nil?
    return render_json status: 'Invalid username or password.' unless user.correct_password params[:password]
    login_user(user)
    render_json status: 'ok', user: user.decorate.gui_hash, friends: redis.user_friends_set(user.username).members
  end

  def follow
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' unless user
    redis.user_friends_set(current_username) << user.username
    render_json status: 'ok'
  end

  def unfollow
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' unless User.exist?(params[:username])
    redis.user_friends_set(current_username).delete user.username
    render_json status: 'ok'
  end

  def username
    if logged_in?
      user = object_store.get(User, current_username)
      return render_json status: 'User does not exist.' if user.nil?
      return render_json status: 'User account has been disabled.' if user.status != 'active' || user.password.nil?
      return render_json status: 'ok', user: user.decorate.gui_hash, friends: redis.user_friends_set(user.username).members
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
    return render_json status: 'Username already exists.' if object_store.get(User, user.username)
    return render_json status: 'Email address is not valid.' if (user.email =~ /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) != 0
    return render_json status: 'Password must be at least six characters long.' if params[:password].length < 6
    return render_json status: 'Passwords do not match.' if params[:password] != params[:password2]
    user.set_password params[:password]
    object_store.save user, user.username
    redis.user_set << user.username
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
    user = object_store.get User, current_username
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'Invalid username or password.' unless user.correct_password params[:old_password]
    user.set_password params[:new_password]
    object_store.save user, user.username
  end

end