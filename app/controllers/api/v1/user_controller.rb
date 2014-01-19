class API::V1::UserController < BaseRedisController

  def auth
    @user = redis.user_store.get(params[:username])
    unless @user && @user.correct_password(params[:password])
      render json: {:status => 'incorrect password or username'}, status: 401 and return
    end
    render_json :status => 'ok', :key => build_key(@user.username)
  end

  def test
    unless valid_key?(params[:key].to_s)
      render json: {:status => 'key not valid'}, status: 401 and return
    end
    render_json :status => 'ok'
  end

  def new_seamail
    unless valid_key?(params[:key].to_s)
      render json: {:status => 'key not valid'}, status: 401 and return
    end
    username = get_username(params[:key])
    render_json :status => 'ok', email_count: redis.inbox_index(username).size
  end

  def get_username(key)
    username = key.split(':').first
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