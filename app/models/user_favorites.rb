class UserFavorites

  def initialize(redis, username, post_ids)
    user_following = redis.user_following(username)
    @favorites_map = Hash[
        post_ids.map do |post_id|
          favorites = redis.post_favorites_set(post_id)
          hash = {
              user_like: favorites.member?(username),
              friends_like: favorites & user_following,
              like_count: favorites.count
          }
          hash[:like_count] -= 1 if hash[:user_like]
          hash[:like_count] -= hash[:friends_like].count
          [ post_id, hash ]
        end
    ]
  end

  def user_like(post_id)
    return false unless @favorites_map.has_key? post_id
    @favorites_map[post_id][:user_like]
  end

  def friends_like(post_id)
    return [] unless @favorites_map.has_key? post_id
    @favorites_map[post_id][:friends_like]
  end

  def like_count(post_id)
    return 0 unless @favorites_map.has_key? post_id
    @favorites_map[post_id][:like_count]
  end

end