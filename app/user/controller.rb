require 'bcrypt'
require 'json'

module App
  module User
    actionize!

    post 'login' do
      user = server.get_user(params[:username])
      return render_json status: 'User does not exist.', foo: 'bar' if user.nil?
      return render_json status: 'Invalid username or password.' if BCrypt::Password.new(user.password) != @params[:password]
      @session[:username] = user.username
      @session[:is_admin] = user.is_admin
      render_json status: 'ok', user: user.view_model
    end

    get 'username' do
      return render_json status: 'ok', user: { username: @session[:username], is_admin: @session[:is_admin] } unless @session[:username].nil?
      render_json status: 'logout'
    end

    get 'logout' do
      @session[:username] = nil
      @session[:is_admin] = false
      render_json status: 'ok'
    end

  end
end