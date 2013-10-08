module PostScoreTrait
  def score(likes_count)
    post_time + likes_count * 3600
  end
end