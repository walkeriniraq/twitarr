class PostFavoriteInfoContext
  include HashInitialize

  fattr %w(posts user post_favorites_factory)

  def call
    self.posts.map do |post|
      post.gui_hash
      #to_hash %w(message username post_time post_id liked liked_sentence)
      #post_favorites = post_favorites_factory.call(post.post_id)
      #post_favorites.member? user.username
      #post_favorites.count
    end
  end

end