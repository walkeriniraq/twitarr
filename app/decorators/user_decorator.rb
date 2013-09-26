class UserDecorator < DraperDecorator
  delegate_all

  def gui_hash
    to_hash %w(username is_admin friends)
  end
  
  def admin_hash
    to_hash %w(username is_admin status email empty_password)
  end

end
