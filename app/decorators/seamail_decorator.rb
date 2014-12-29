class SeamailDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::TextHelper

  def to_meta_hash
    {
        id: id.to_s,
        users: usernames,
        display_names: display_names,
        subject: subject,
        messages: pluralize(seamail_count, 'message'),
        timestamp: last_message
    }
  end

  def to_hash
    {
        id: id.to_s,
        users: usernames,
        display_names: display_names,
        subject: subject,
        messages: messages.map { |x| x.decorate.to_hash }
    }
  end

end