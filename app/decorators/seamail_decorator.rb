class SeamailDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::TextHelper

  def to_meta_hash
    {
        id: id.to_s,
        users: usernames.map { |x| { username: x, display_name: User.display_name_from_username(x), last_photo_updated: User.last_photo_updated_from_username(x) }},
        subject: subject,
        messages: pluralize(seamail_count, 'message'),
        timestamp: last_message
    }
  end

  def to_hash
    {
        id: id.to_s,
        users: usernames.map { |x| { username: x, display_name: User.display_name_from_username(x), last_photo_updated: User.last_photo_updated_from_username(x) }},
        subject: subject,
        messages: messages.map { |x| x.decorate.to_hash }
    }
  end

end