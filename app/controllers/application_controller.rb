class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def logged_in?
    !current_username.nil?
  end

  def current_username
    session[:username]
  end

  def current_user
    @user ||= User.get current_username
  end

  def login_user(user)
    session[:username] = user.username
    session[:is_admin] = user.is_admin
  end

  def logout_user
    session.delete :username
    session.delete :is_admin
  end

  def is_admin?
    session[:is_admin]
  end

  def login_required
    render json: { status: 'Not logged in.' }
  end

  def read_only_mode
    render json: { status: 'Twit-arr is in storage (read-only) mode.' }
  end

  def render_json(hash)
    render json: hash
  end

  def get_username(key)
    key.split(':').first
  end

  def valid_key?(key)
    return false if key.nil?
    return false unless key.include? ':'
    username = get_username key
    CHECK_DAYS_BACK.times do |x|
      return true if build_key(username, x) == key
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
