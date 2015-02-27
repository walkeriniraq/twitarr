class AnnouncementDecorator < BaseDecorator
  delegate_all
  include Twitter::Autolink

  def to_hash
    {
        id: as_str(id),
        author: author,
        display_name: User.display_name_from_username(author),
        text: twitarr_auto_linker(text.gsub("\n", '<br />')),
        timestamp: timestamp
    }
  end

  def to_admin_hash
    {
        id: as_str(id),
        author: author,
        text: text,
        timestamp: timestamp,
        valid_until: valid_until.strftime('%F %l:%M%P')
    }
  end

end