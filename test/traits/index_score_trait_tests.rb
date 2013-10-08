module IndexScoreTraitTests

  def test_index_according_to_score
    post = OpenStruct.new post_id: 1
    post.expects(:score).with(4).returns(24)
    index = {}
    role = subject.new(index)
    role.add_post(post, 4)
    index[1].must_equal 24
  end

end