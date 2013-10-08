module IndexScoreTrait
  def add_post(post, likes_count)
    self[post.post_id] = post.score(likes_count)
  end
end