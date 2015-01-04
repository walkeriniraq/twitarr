class AnnouncementDecorator < Draper::Decorator
  delegate_all

  def to_admin_hash
    {
        id: id.to_s,
        author: author,
        text: text,
        timestamp: timestamp,
        valid_until: valid_until.strftime('%F %T')
    }
  end

end