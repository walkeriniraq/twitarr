class AnnouncementDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        author: author,
        display_name: User.display_name_from_username(author),
        text: text.gsub("\n", '<br />'),
        timestamp: timestamp
    }
  end

  def to_admin_hash
    {
        id: id.to_s,
        author: author,
        text: text,
        timestamp: timestamp,
        valid_until: valid_until.strftime('%F %l:%M%P')
    }
  end

end