require 'bcrypt'
require 'json'

class UserController < ApplicationController
  skip_around_action :redis_context_filter, only: [:logout]

  def login
    user = object_store.get(User, params[:username].downcase)
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'User account has been disabled.' if user.status != 'active' || user.password.nil?
    return render_json status: 'Invalid username or password.' unless user.correct_password params[:password]
    login_user(user)
    render_json user_hash(user)
  end

  def user_hash(user)
    {
        status: 'ok',
        user: user.decorate.gui_hash,
        friends: redis.user_friends_set(user.username).members,
        new_email: redis.inbox_index(user.username).size
    }
  end

  def follow
    to = params[:username].downcase
    return render_json status: 'User does not exist.' unless TwitarrDb.user(to)
    TwitarrDb.follow(current_username, to)
    render_json status: 'ok'
  end

  def unfollow
    TwitarrDb.unfollow(current_username, params[:username].downcase)
    render_json status: 'ok'
  end

  def message
    puts "PASSED MESSAGE: #{params[:message].inspect}"
    render_json status: 'ok'
  end

  def username
    if logged_in?
      if current_user.nil?
        # this is a special case - need to log the current user out
        logout_user
        return render_json status: 'User does not exist.'
      end
      return render_json status: 'User account has been disabled.' if current_user.status != 'active' || current_user.password.nil?
      return render_json user_hash(current_user)
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
    return render_json status: 'User does not exist.' if current_user.nil?
    return render_json status: 'Invalid username or password.' unless current_user.correct_password params[:old_password]
    current_user.set_password params[:new_password]
    object_store.save current_user, current_user.username
  end

end