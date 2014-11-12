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
    render_json names: User.where(username: /^#{params[:username]}/).map(:username)
  end

  def whoami
    return unless logged_in!
    render_json :status => 'ok', user: UserDecorator.decorate(current_user).self_hash
  end

  def show
    return unless logged_in!
    user = User.where(username: params[:username]).first
    unless user
      render status: :not_found, json: {status: 'Not found', error: "User #{params[:username]} is not found."}
      return
    end
    if current_user.is_admin && params[:admin]
      render status: :ok, json: {status: 'Found', user: UserDecorator.decorate(user).admin_hash}
    else
      render status: :ok, json: {status: 'Found', user: UserDecorator.decorate(user).gui_hash}
    end
  end

  def logout
    logout_user
    render_json status: 'ok'
  end
end