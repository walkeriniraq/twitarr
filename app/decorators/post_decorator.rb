class PostDecorator < Draper::Decorator
  delegate_all

  def gui_hash(favorites)
    ret = to_hash %w(message username post_time post_id)
    ret[:user_liked] = favorites.user_like(post_id)
    ret[:friends_liked] = favorites.friends_like(post_id)
    ret[:others_liked] = favorites.like_count(post_id)
    ret
  end

  def announcement_hash
    to_hash %w(message username post_time post_id)
  end

end
