module IndexTimeTraitTests

  def test_index_according_to_time
    post = OpenStruct.new time_index: DateTime.now, post_id: 1
    index = {}
    role = subject.new(index)
    role.add_post(post)
    index[1].must_equal post.time_index
  end

end