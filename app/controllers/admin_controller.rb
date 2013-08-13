module AdminController
  def no_access
    return login_required unless logged_in?
    return render_json status: 'Restricted to admin.' unless is_admin?
    'Unknown access error'
  end

  def has_access?
    logged_in? && is_admin?
  end

  #post 'activate' do
  #  return no_access unless has_access?
  #  user = server.get_user(params[:username])
  #  return render_json status: 'User does not exist.' if user.nil?
  #  user.status = 'active'
  #  server.write_user user
  #  render_json status: 'ok'
  #end
  #
  #post 'update_user' do
  #  return no_access unless has_access?
  #  user = server.get_user params[:data]['username']
  #  user.update(params[:data])
  #  # don't let the user turn off his own admin status
  #  user.is_admin = true if user.username == current_username
  #  server.write_user user
  #  render_json status: 'ok'
  #end
  #
  #post 'add_user' do
  #  return no_access unless has_access?
  #  user = User.new
  #  user.update(params[:data])
  #  return render_json status: 'Username already exists.' if server.user_exist? user.username
  #  return render_json status: 'Username cannot contain : character.' if user.username.include? ':'
  #  return render_json status: 'Username must be at least six characters.' if user.username.nil? || user.username.length < 6
  #  server.write_user user
  #  render_json status: 'ok'
  #end
  #
  #post 'delete_user' do
  #  return no_access unless has_access?
  #  return render_json status: 'User does not exist.' unless server.user_exist? params[:username]
  #  return render_json status: 'Cannot delete own account!' unless params[:username] != current_username
  #  server.redis_connection.srem('users', params[:username])
  #  server.redis_connection.del "user:#{params[:username]}"
  #  render_json status: 'ok'
  #end
  #
  #post 'reset_password' do
  #  return no_access unless has_access?
  #  return render_json status: 'Password must be at least six characters long.' if params[:new_password].length < 6
  #  user = server.get_user(params[:username])
  #  return render_json status: 'User does not exist.' if user.nil?
  #  user.password = BCrypt::Password.create params[:new_password]
  #  server.write_user user
  #  render_json status: 'ok'
  #end
  #
  #get 'index' do
  #  return render_file 'app/admin/unauthorized.html' unless has_access?
  #  render_file 'app/admin/admin_index.html'
  #end
  #
  #get 'users' do
  #  return no_access unless has_access?
  #  redis = server.redis_connection
  #  users = redis.smembers('users').map do |username|
  #    server.get_user(username).to_hash [:username, :is_admin, :status, :email, :empty_password]
  #  end
  #  render_json list: users
  #end

end