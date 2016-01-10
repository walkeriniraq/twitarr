class UserDecorator < Draper::Decorator
  delegate_all

  def return_attribute_hash(attributes)
    attributes.reduce({}) { |h, k| h[k] = send(k); h }
  end

  def public_hash
    attrs = %w(username display_name current_location number_of_tweets number_of_mentions room_number real_name home_location last_photo_updated vcard_public?)
    attrs.push(:email) if email_public?
    return_attribute_hash attrs
  end

  def gui_hash
    return_attribute_hash %w(username is_admin display_name last_photo_updated)
  end
  
  def admin_hash
    return_attribute_hash %w(username is_admin status email email_public? vcard_public? display_name current_location last_login empty_password? last_photo_updated room_number real_name home_location)
  end

  def self_hash
    hsh = admin_hash
    hsh[:unnoticed_alerts] = unnoticed_alerts
    hsh
  end

  def alerts_meta
    return_attribute_hash %w(seamail_unread_count unnoticed_mentions unnoticed_alerts unnoticed_announcements)
  end

end
