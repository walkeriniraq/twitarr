module PostScoreTrait
  def score(likes_count)
    post_time + likes_count * 1.hours
  end
end