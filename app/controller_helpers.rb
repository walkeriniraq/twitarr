module ControllerHelpers
  def logged_in?
    !current_username.nil?
  end

  def current_username
    @session[:username]
  end

  def is_admin?
    @session[:is_admin]
  end

  def login_required
    render_json status: 'Not logged in.'
  end

end