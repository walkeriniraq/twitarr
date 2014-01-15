class UserFavorites

  def initialize(redis, username, post_ids)
    @favorites_map = Hash[
        post_ids.map do |post_id|
          favorites = redis.post_favorites_set(post_id)
          hash = {
              user_like: favorites.member?(username),
              like_count: favorites.count,
          }
          hash[:like_count] -= 1 if hash[:user_like]
          hash[:likes] = favorites.members - [username] if hash[:like_count] < 5
          [ post_id, hash ]
        end
    ]
  end

  def likes(post_id)
    return false unless @favorites_map.has_key? post_id
    @favorites_map[post_id][:likes]
  end

  def user_like(post_id)
    return false unless @favorites_map.has_key? post_id
    @favorites_map[post_id][:user_like]
  end

  def like_count(post_id)
    return 0 unless @favorites_map.has_key? post_id
    @favorites_map[post_id][:like_count]
  end

end