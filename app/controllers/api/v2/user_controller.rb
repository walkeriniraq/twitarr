class API::V2::UserController < ApplicationController
  skip_before_action :verify_authenticity_token

  def auth
    login_result = validate_login params[:username], params[:password]
    if login_result.has_key? :error
      render json: { :status => 'incorrect password or username' }, status: 401 and return
    else
      @user = login_result[:user]
      login_user @user
      render json: { :status => 'ok', :key => build_key(@user.username) }
    end
  end

  def new_seamail
    return unless logged_in!
    render_json :status => 'ok', email_count: current_user.seamail_unread_count
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
    user = User.get params[:username]
    unless user
      render status: :not_found, json: { status: 'Not found', error: "User #{params[:username]} is not found." }
      return
    end
    if current_user.is_admin && params[:admin]
      render status: :ok, json: { status: 'Found', user: UserDecorator.decorate(user).admin_hash }
    else
      render status: :ok, json: { status: 'Found', user: UserDecorator.decorate(user).gui_hash }
    end
  end

  def get_photo
    user = User.get params[:username]
    response.headers['Etag'] = user.photo_hash
    expires_in 1.second
    if user
      if params[:full]
        send_file user.full_profile_picture_path, disposition: 'inline'
      else
        send_file user.profile_picture_path, disposition: 'inline'
      end

    else
      Rails.logger.error "get_photo: User #{params[:username]} was not found.  Using 404 image."
      redirect_to '/img/404_file_not_found_sign_by_zutheskunk.png'
    end
  end

  def reset_photo
    return unless logged_in!
    render_json current_user.reset_photo
  end

  def update_photo
    return unless logged_in!
    render_json(status: 'Must provide a photo to upload.') and return unless params[:file]
    render_json current_user.update_photo params[:file]
  end

  def reset_mentions
    return unless logged_in!
    current_user.reset_mentions
    render status: :ok, json: { status: 'OK', user: UserDecorator.decorate(current_user).self_hash }
  end

  def mentions
    return unless logged_in!
    render status: :ok, json: { mentions: current_user.unnoticed_mentions }
  end

  def likes
    return unless logged_in!
    limit = params[:limit] || 20
    skip = params[:skip] || 0
    query = current_user.liked_posts.limit(limit).skip(skip)
    count = query.length
    result = [status: 'ok', user: current_user.username, total_count: count, next: (skip + limit), items: query.length, likes: query]
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