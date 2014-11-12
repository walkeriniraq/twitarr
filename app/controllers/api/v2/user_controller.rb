class API::V2::UserController < ApplicationController
  skip_before_action :verify_authenticity_token

  def auth
    login_result = validate_login params[:username], params[:password]
    if login_result.has_key? :error
      render json: {:status => 'incorrect password or username'}, status: 401 and return
    else
      @user = login_result[:user]
      login_user @user
      render json: {:status => 'ok', :key => build_key(@user.username)}
    end
  end

  def new_seamail
    return unless logged_in!
    render_json :status => 'ok', email_count: current_user.seamail_count
  end

  def autocomplete
    render_json names: User.where(username: /^#{params[:string]}/).map(:username)
  end

  def whoami
    return unless logged_in!
    render_json :status => 'ok', user: {
                                   username: current_user.username,
                                   display_name: current_user.display_name,
                                   admin: current_user.is_admin,
                                   email: current_user.email,
                                   last_login: current_user.last_login,
                                   session_id: session.id
                               }
  end

  def logout
    logout_user
    render_json status: 'ok'
  end
end