module IndexPostTimeTrait
  def add_post(post)
    self[post.post_id] = post.time_index
  end
end