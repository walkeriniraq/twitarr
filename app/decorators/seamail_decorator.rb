class SeamilDecorator < Draper::Decorator
  delegate_all

  def gui_hash
    to_hash %w(email_id from to subject text sent_time)
  end

end