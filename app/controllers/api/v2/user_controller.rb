class API::V2::UserController < ActionController::Base

  def auth
    @user = redis.user_store.get(params[:username].downcase)
    unless @user && @user.correct_password(params[:password])
      render json: {:status => 'incorrect password or username'}, status: 401 and return
    end
    render_json :status => 'ok', :key => build_key(@user.username)
  end

  def new_seamail
    unless valid_key?(params[:key].to_s)
      render json: {:status => 'key not valid'}, status: 401 and return
    end
    username = get_username(params[:key])
    render_json :status => 'ok', email_count: redis.inbox_index(username).size
  end

end