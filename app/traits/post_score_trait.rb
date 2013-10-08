module PostScoreTrait
  def score(likes_count)
    post_time.to_f + likes_count * 3600
  end
end