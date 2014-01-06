require 'test_helper'

class UserFavoritesTest < BaseTestCase
  subject { UserFavorites }

  def setup
    favorites = (0..4).map { |x| redis.post_favorites_set(x) }

    favorites[1] << 'dave' << 'walter'
    favorites[2] << 'steve' << 'walter'
    favorites[3] << 'sally' << 'walter'
    favorites[4] << 'sally' << 'steve' << 'walter'

    @test_obj = UserFavorites.new(redis, 'steve', [0, 1, 2, 3])
  end

  it 'user_like returns false for posts not in the list' do
    @test_obj.user_like(4).must_equal false
  end

  it 'user_like returns false for unliked posts' do
    @test_obj.user_like(1).must_equal false
  end

  it 'user_like returns true for liked posts' do
    @test_obj.user_like(2).must_equal true
  end

  it 'like_count is zero for posts not in list' do
    @test_obj.like_count(4).must_equal 0
  end

  it 'like_count is zero for unliked posts' do
    @test_obj.like_count(0).must_equal 0
  end

  it 'like_count is correct for liked posts' do
    @test_obj.like_count(1).must_equal 2
  end

  it 'like_count does not include user' do
    @test_obj.like_count(2).must_equal 1
  end

  def teardown
    (0..4).each { |x| redis.post_favorites_set(x).clear }
  end

end
