require 'bcrypt'
require 'json'

class UserController < ApplicationController

  def login
    user = redis.user_store.get(params[:username].downcase)
    if user.nil?
      flash[:danger] = 'User does not exist.'
      render :login_page, layout: false
    elsif user.status != 'active' || user.password.nil?
      flash[:danger] = 'User account has been disabled.'
      render :login_page, layout: false
    elsif !user.correct_password(params[:password])
      flash[:danger] = 'Invalid username or password.'
      render :login_page, layout: false
    else
      login_user(user)
      redis.user_store.save user.update_last_login, current_username
      redirect_to :root
    end
  end

  def login_page
    render :layout => false
  end

  def user_hash(user)
    {
        status: 'ok',
        user: user.decorate.gui_hash
    }
  end

  def username
    if logged_in?
      if current_user.nil?
        # this is a special case - need to log the current user out
        logout_user
        return render_json status: 'User does not exist.'
      end
      return render_json status: 'User account has been disabled.' if current_user.status != 'active' || current_user.password.nil?
      redis.user_store.save current_user.update_last_login, current_username
      return render_json user_hash(current_user)
    end
    render_json status: 'logout'
  end

  def new
    user = User.new
    user.username = params[:new_username].downcase
    user.email = params[:email]
    user.status = 'active'
    user.is_admin = false
    if !User.valid_username? params[:new_username]
      flash[:danger] = 'Username must be three or more characters and only include letters, numbers, underscore, dash, and ampersand'
      render :login_page, layout: false
    elsif redis.user_store.get(user.username)
      flash[:danger] = 'Username already exists.'
      render :login_page, layout: false
    elsif (user.email =~ /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) != 0
      flash[:danger] = 'Email address is not valid.'
      render :login_page, layout: false
    elsif params[:new_password].length < 6
      flash[:danger] = 'Password must be at least six characters long.'
      render :login_page, layout: false
    elsif params[:new_password] != params[:new_password2]
      flash[:danger] = 'Passwords do not match.'
      render :login_page, layout: false
    else
      user.set_password params[:new_password]
      TwitarrDb.add_user user
      login_user(user)
      redis.user_store.save user.update_last_login, current_username
      redirect_to :root
    end
  end

  def update_status
    return render_json(status: 'logout') unless logged_in?
    render_json status: 'ok',
                new_email: redis.inbox_index(current_user.username).size,
                new_posts: redis.tag_index("@#{current_user.username}").range_size(current_user.last_checked_posts, Time.now.to_f)
  end

  def logout
    logout_user
    render_json status: 'ok'
  end

  def autocomplete
    render_json status: 'ok', names: redis.user_auto.query(params[:string])
  end

  def change_password
    return login_required unless logged_in?
    return render_json status: 'Password must be at least six characters long.' if params[:new_password].length < 6
    return render_json status: 'New passwords do not match.' if params[:new_password] != params[:new_password2]
    return render_json status: 'User does not exist.' if current_user.nil?
    return render_json status: 'Invalid username or password.' unless current_user.correct_password params[:old_password]
    current_user.set_password params[:new_password]
    redis.user_store.save current_user, current_user.username
  end

  def profile
    return login_required unless logged_in?
    render_json status: 'ok', display_name: current_user.display_name
  end

end
