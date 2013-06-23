require 'bcrypt'
require 'json'

require_relative '../controller_helpers.rb'

module UserController
  actionize!

  include ControllerHelpers

  post 'login' do
    user = server.get_user(params[:username])
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'User account has been disabled.' if user.status != 'active' || user.password.nil?
    return render_json status: 'Invalid username or password.' if BCrypt::Password.new(user.password) != @params[:password]
    @session[:username] = user.username
    @session[:is_admin] = user.is_admin
    render_json status: 'ok', user: user.to_hash([:username, :is_admin])
  end

  get 'username' do
    return render_json status: 'ok', user: { username: @session[:username], is_admin: @session[:is_admin] } unless @session[:username].nil?
    render_json status: 'logout'
  end

  post 'new_user' do
    user = User.new
    user.username = params[:username]
    user.email = params[:email]
    user.status = 'inactive'
    user.is_admin = false
    return render_json status: 'Username must be at least six characters.' if user.username.nil? || user.username.length < 6
    return render_json status: 'Username cannot contain : character.' if user.username.include? ':'
    return render_json status: 'Username already exists.' if server.user_exist? user.username
    return render_json status: 'Email address is not valid.' if (user.email =~ /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i) != 0
    return render_json status: 'Password must be at least six characters long.' if @params[:password].length < 6
    return render_json status: 'Passwords do not match.' if @params[:password] != @params[:password2]
    user.password = BCrypt::Password.create @params[:password]
    server.write_user user
    render_json status: 'ok'
  end

  get 'logout' do
    @session[:username] = nil
    @session[:is_admin] = false
    render_json status: 'ok'
  end

  post 'change_password' do
    return login_required unless logged_in?
    return render_json status: 'Password must be at least six characters long.' if @params[:new_password].length < 6
    return render_json status: 'New passwords do not match.' if @params[:new_password] != @params[:new_password2]
    user = server.get_user(username)
    return render_json status: 'User does not exist.' if user.nil?
    return render_json status: 'Invalid username or password.' if BCrypt::Password.new(user.password) != @params[:old_password]
    user.password = BCrypt::Password.create @params[:new_password]
    server.write_user user
  end

end