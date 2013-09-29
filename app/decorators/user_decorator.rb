class UserDecorator < Draper::Decorator
  delegate_all

  def gui_hash
    to_hash %w(username is_admin)
  end
  
  def admin_hash
    to_hash %w(username is_admin status email empty_password)
  end

end
