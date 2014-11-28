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

  def get_photo
    user = User.where(username: params[:username]).first
    send_file user.profile_picture_path, disposition: 'inline'
  end

  def reset_photo
    return unless logged_in!

    if params[:username] != current_user and not current_user.is_admin
      render json: {message: 'Unable to modify another user\'s profile picture.', status: 'err'}, status: :forbidden
      return
    end

    if params[:username] != current_username
      user = User.where(username: params[:username]).first
    else
      user = current_user
    end
    unless user
      render status: :not_found, json: {status: 'Not found', error: "User #{params[:username]} is not found."}
      return
    end
    user.set_profile_image_as_identicon
  end

  def update_photo
    return unless logged_in!
    puts params
    return render json: {message: 'Must provide a photo to upload.', status: 'err'}, status: :bad_request unless params[:file]

    if params[:username] != current_username and not current_user.is_admin
      render json: {message: 'Unable to modify another user\'s profile picture.', status: 'err'}, status: :forbidden
      return
    end

    if params[:username] != current_user
      user = User.where(username: params[:username]).first
    else
      user = current_user
    end
    unless user
      render status: :not_found, json: {status: 'Not found', error: "User #{params[:username]} is not found."}
      return
    end

    user.profile_picture_from_file params[:file]
    render json:{status:'ok', message:'updated user\'s profile picture'}
  end

  def likes
    return unless logged_in!
    limit = params[:limit] || 20
    skip = params[:skip] || 0
    query = current_user.liked_posts.limit(limit).skip(skip)
    count = query.length
    result = [status: 'ok', user:current_user.username, total_count:count, next:(skip + limit), items:query.length, likes:query]
    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end

  def logout
    logout_user
    render_json status: 'ok'
  end
end