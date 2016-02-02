class AdminController < ApplicationController

  def no_access
    return login_required unless logged_in?
    return render_json status: 'Restricted to admin.' unless is_admin?
    'Unknown access error'
  end

  def has_access?
    logged_in? && is_admin?
  end

  def users
    return no_access unless has_access?
    render_json status: 'ok', list: User.all.asc(:username).map { |x| x.decorate.admin_hash }
  end

  def user
    return no_access unless has_access?
    search_text = params[:text].strip.downcase.gsub(/[^0-9A-Za-z_]/, '')
    user_query = User.search(params)
    render_json status: 'ok', search_text: search_text, users: user_query.map{|x| x.decorate.admin_hash }
  end

  def update_user
    return no_access unless has_access?
    user = User.get(params[:username])
    return render_json status: 'User does not exist.' unless user
    user.is_admin = params[:is_admin] == 'true'
    # don't let the user turn off his own admin status
    user.is_admin = true if user.username == current_username
    user.status = params[:status]
    user.email = params[:email]
    user.display_name = params[:display_name]
    if user.invalid?
      render_json(status: 'invalid', errors: user.errors.full_messages) and return
    end
    user.save
    render_json status: 'ok'
  end

  def add_user
    return no_access unless has_access?
    user = User.new(params)
    user.is_admin = params[:is_admin] == 'true'
    if user.invalid?
      render_json(status: 'invalid', errors: user.errors.full_messages) and return
    end
    user.save
    render_json status: 'ok'
  end

  def activate
    return no_access unless has_access?
    user = User.get(params[:username])
    return render_json status: 'User does not exist.' unless user
    user.status = User::ACTIVE_STATUS
    user.save
    render_json status: 'ok'
  end

  def reset_password
    return no_access unless has_access?
    user = User.get(params[:username])
    return render_json status: 'User does not exist.' unless user
    user.password = BCrypt::Password.create User::RESET_PASSWORD
    user.save
    render_json status: 'ok'
  end

  def new_announcement
    return no_access unless has_access?
    time = Time.now
    valid_until = time + params[:hours].to_i.hours
    return render_json status: 'Announcement hours must be greater than zero.' unless valid_until > time
    Announcement.create(author: current_username, text: params[:text], timestamp: time, valid_until: valid_until)
    render_json status: 'ok'
  end

  def announcements
    return no_access unless has_access?
    render_json status: 'ok', list: Announcement.all.desc(:timestamp).map { |x| x.decorate.to_admin_hash }
  end

end