require 'bcrypt'
require 'json'

class UserController < ApplicationController

  layout 'login'

  def login
    user = redis.user_store.get(params[:username].downcase)
    if user.nil?
      @error = 'User does not exist.'
      render :login_page
    elsif user.status != 'active' || user.password.nil?
      @error = 'User account has been disabled.'
      render :login_page
    elsif !user.correct_password(params[:password])
      @error = 'Invalid username or password.'
      render :login_page
    else
      login_user(user)
      redis.user_store.save user.update_last_login, current_username
      redirect_to :root
    end
  end

  def login_page
  end

  def create_user
  end

  def forgot_password
  end

  def security_question
    @user = redis.user_store.get(params[:username])
    if @user.nil?
      @error = 'User does not exist.'
      render :forgot_password
    end
  end

  def security_answer
    @user = redis.user_store.get(params[:username])
    if @user.nil?
      @error = 'User does not exist.'
      render :forgot_password
    end
    if params[:security_answer].downcase.strip != @user.security_answer ||
        params[:email].strip != @user.email
      sleep 30.seconds.to_i
      @error = 'Email or security answer did not match.'
      render :security_question and return
    end
    @user.set_password 'seamonkey'
    redis.user_store.save @user, @user.username
    @error = 'Password has been reset to "seamonkey"'
    render :login_page
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
      return render_json status: 'ok', user: current_user.decorate.gui_hash
    end
    render_json status: 'logout'
  end

  def new
    unless Twitarr::Application.config.allow_new_users
      render text: 'New user creation has been temporarily disabled!' and return
    end
    @user = User.new username: params[:new_username].downcase,
                     email: params[:email],
                     status: 'active',
                     is_admin: false,
                     security_question: params[:security_question],
                     security_answer: params[:security_answer].downcase.strip
    if !@user.valid?
      render :create_user
    elsif redis.user_store.get(@user.username)
      flash[:danger] = 'Username already exists.'
      render :create_user
    elsif params[:new_password].length < 6
      flash[:danger] = 'Password must be at least six characters long.'
      render :create_user
    elsif params[:new_password] != params[:new_password2]
      flash[:danger] = 'Passwords do not match.'
      render :create_user
    else
      @user.set_password params[:new_password]
      TwitarrDb.add_user @user
      login_user(@user)
      redis.user_store.save @user.update_last_login, current_username
      redirect_to :root
    end
  end

  def profile_save
    return login_required unless logged_in?
    user = current_user.dup
    user.display_name = params[:display_name]
    return render_json status: 'error', errors: user.errors.full_messages unless user.valid?
    current_user.display_name = params[:display_name]
    DisplayNameCache.set_display_name current_username, params[:display_name]
    redis.user_store.save current_user, current_username
    render_json status: 'ok'
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
    render_json status: 'ok'
  end

  def profile
    return login_required unless logged_in?
    render_json status: 'ok', display_name: current_user.display_name
  end

end
