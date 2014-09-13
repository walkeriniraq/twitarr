class StreamPostDecorator < Draper::Decorator
  delegate_all

  def to_hash
    {
        id: id,
        author: author,
        text: text,
        timestamp: timestamp,
        photo: photo
    }
  end

  # def gui_hash_with_favorites(favorites)
  #   ret = to_hash %w(message username post_time post_id)
  #   ret[:liked_sentence] = liked_sentence favorites
  #   ret[:user_liked] = favorites.user_like(post_id)
  #   ret
  # end
  #
  # def gui_hash
  #   to_hash %w(message username post_time post_id)
  # end
  #
  # def liked_sentence(favorites)
  #   likes = []
  #   likes << 'You' if favorites.user_like(post_id)
  #   other_likes = favorites.like_count(post_id)
  #   likes << "#{other_likes} people" if other_likes > 1
  #   likes << '1 other person' if other_likes == 1
  #   return case
  #            when likes.count > 1
  #              "#{likes[0..-2].join ', '} and #{likes.last} like this."
  #            when likes.count > 0
  #              if likes.first == 'You'
  #                'You like this.'
  #              elsif other_likes > 1
  #                "#{likes.first} like this."
  #              else
  #                "#{likes.first} likes this."
  #              end
  #          end
  # end
  #
  # def announcement_hash
  #   to_hash %w(message username post_time post_id)
  # end

end
