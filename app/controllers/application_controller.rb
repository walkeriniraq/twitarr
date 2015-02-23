class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception

  def logged_in?
    !current_username.nil?
  end

  def current_username
    return @user.username if @user
    session[:username]
  end

  def current_user
    @user ||= User.get current_username
  end

  def login_user(user)
    session[:username] = user.username
    session[:is_admin] = user.is_admin
    puts "Successful login for user: #{current_username}"
  end

  def logout_user
    session.delete :username
    session.delete :is_admin
  end

  def is_admin?
    (@user && @user.is_admin) || session[:is_admin]
  end

  def logged_in!
    unless valid_key?(params[:key]) || logged_in?
      render json: {:status => 'key not valid'}, status: 401 and return false
    end
    true
  end

  def validate_login(username, password)
    user = User.get username
    result = {user: user}
    if user.nil?
      result[:error] = 'User does not exist.'
    elsif user.status != User::ACTIVE_STATUS|| user.empty_password?
      result[:error] = 'User account has been disabled.'
    elsif !user.correct_password(password)
      result[:error] = 'Invalid username or password.'
    else
      user.update_last_login.save
    end
    result
  end


  def login_required
    render json: { status: 'Not logged in.' }
  end

  def read_only_mode
    render json: { status: 'Twit-arr is in storage (read-only) mode.' }
  end

  def render_json(hash)
    render json: hash.update({server_time: (DateTime.now.to_f * 1000).to_i})
  end

  def get_username(key)
    key.split(':').first
  end

  def login_with_key(key)
    @user = User.get get_username(key)
  end

  def valid_key?(key)
    return false if key.nil?
    return false unless key.include? ':'
    username = get_username key
    CHECK_DAYS_BACK.times do |x|
      if build_key(username, x) == key
        login_with_key key
        return true
      end
    end
    false
  end

  def build_key(name, days_back = 0)
    digest = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA1.new,
        Twitarr::Application.config.secret_key_base,
        "#{name}#{Time.now.year}#{Time.now.yday - days_back}"
    )
    "#{name}:#{digest}"
  end

  CHECK_DAYS_BACK = 10

end
