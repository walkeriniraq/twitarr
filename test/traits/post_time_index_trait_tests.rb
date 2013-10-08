module PostTimeIndexTraitTests

  def test_time_index_based_on_post_time
    post = OpenStruct.new post_time: Time.now.to_f
    role = subject.new(post)
    role.time_index.must_equal post.post_time
  end

end


