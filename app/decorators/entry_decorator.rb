class EntryDecorator < Draper::Decorator
  delegate_all

  def gui_hash
    to_hash %w(entry_id type time from message data)
  end

end