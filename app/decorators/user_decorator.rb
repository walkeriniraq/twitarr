class UserDecorator < Draper::Decorator
  delegate_all

  def gui_hash
    to_hash %w(username is_admin friends)
  end

end
