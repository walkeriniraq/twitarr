class API::V1::UserController < BaseRedisController

  def auth
    @user = redis.user_store.get(params[:username])
    unless @user && @user.correct_password(params[:password])
      render json: {:status => 'incorrect password or username'}, status: 401 and return
    end
    render_json :status => 'ok', :key => build_key(@user.username)
  end

  def test
    username = params[:key].split(':').first
    unless params[:key] == build_key(username)
      render json: {:status => 'key not valid'}, status: 401 and return
    end
    render_json :status => 'ok'
  end

  def build_key(name)
    digest = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest::SHA1.new,
        Twitarr::Application.config.secret_key_base,
        name
    )
    "#{name}:#{digest}"
  end

end