class UserDecorator < Draper::Decorator
  delegate_all

  def gui_hash
    to_hash %w(username is_admin display_name)
  end
  
  def admin_hash
    to_hash %w(username display_name is_admin status last_login email empty_password)
  end

end
