class AdminController < ApplicationController

  def no_access
    return login_required unless logged_in?
    return render_json status: 'Restricted to admin.' unless is_admin?
    'Unknown access error'
  end

  def has_access?
    logged_in? && is_admin?
  end

  def users
    return no_access unless has_access?
    users = object_store.get(User, redis.user_set.members)
    render_json status: 'ok', list: UserDecorator.decorate_collection(users).map { |x| x.admin_hash }
  end

  def find_user
    return no_access unless has_access?
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' unless user
    render_json status: 'ok', user: user.decorate.admin_hash
  end

  def update_user
    return no_access unless has_access?
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' unless user
    user.is_admin = params[:is_admin] == 'true'
    # don't let the user turn off his own admin status
    user.is_admin = true if user.username == current_username
    user.status = params[:status]
    user.email = params[:email]
    object_store.save(user, user.username)
    render_json status: 'ok'
  end

  def add_user
    return no_access unless has_access?
    return render_json status: 'Username already exists.' if object_store.get(User, params[:username])
    return render_json status: 'Username cannot contain spaces or the following characters: %#:' unless User.valid_username? params[:username]
    return render_json status: 'Username must be at least six characters.' if params[:username].nil? || params[:username].length < 6
    user = User.new
    user.username = params[:username]
    user.is_admin = params[:is_admin] == 'true'
    user.status = params[:status]
    user.email = params[:email]
    object_store.save user, user.username
    redis.user_set << user.username
    render_json status: 'ok'
  end

  def activate
    return no_access unless has_access?
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' unless user
    user.status = 'active'
    object_store.save(user, user.username)
    render_json status: 'ok'
  end

  def reset_password
    return no_access unless has_access?
    return render_json status: 'Password must be at least six characters long.' if params[:new_password].length < 6
    user = object_store.get(User, params[:username])
    return render_json status: 'User does not exist.' unless user
    user.password = BCrypt::Password.create params[:new_password]
    object_store.save(user, user.username)
    render_json status: 'ok'
  end

end