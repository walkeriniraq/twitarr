class UserDecorator < Draper::Decorator
  delegate_all

  def return_attribute_hash(attributes)
    attributes.reduce({}) { |h, k| h[k] = send(k); h }
  end

  def gui_hash
    return_attribute_hash %w(username is_admin display_name)
  end
  
  def admin_hash
    return_attribute_hash %w(username display_name is_admin status last_login email empty_password? seamail_unread_count unnoticed_mentions)
  end

  def self_hash
    hsh = admin_hash
    hsh[:unnoticed_alerts] = unnoticed_alerts
    hsh
  end

  def alerts_meta
    return_attribute_hash %w(seamail_unread_count unnoticed_mentions unnoticed_alerts)
  end

end
