module PostScoreTraitTests

  def test_score_based_on_time
    post = OpenStruct.new post_time: Time.now.to_f
    role = subject.new(post)
    role.score(0).must_equal post.post_time
  end

  def test_later_has_higher_score
    older_post = OpenStruct.new post_time: Time.now.to_f
    sleep(0.1)
    post = OpenStruct.new post_time: Time.now.to_f
    role = subject.new(post)
    older_role = subject.new(older_post)
    assert_operator role.score(0), :>, older_role.score(0)
  end

  def test_likes_have_higher_score
    older_post = OpenStruct.new post_time: Time.now.to_f
    sleep(0.1)
    post = OpenStruct.new post_time: Time.now.to_f
    role = subject.new(post)
    older_role = subject.new(older_post)
    assert_operator role.score(0), :<, older_role.score(1)
  end

end