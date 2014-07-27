# class EntryDecorator < Draper::Decorator
#   delegate_all
#
#   def gui_hash
#     to_hash %w(entry_id type time from message data)
#   end
#
#   def gui_hash_with_favorites(favorites)
#     ret = to_hash %w(entry_id type time from message data)
#     unless DisplayNameCache.get_display_name(from).nil?
#       ret[:display_name] = DisplayNameCache.get_display_name from
#     end
#     if type == :post
#       ret['data'][:replies].each do |reply|
#         unless DisplayNameCache.get_display_name(reply['username']).nil?
#           reply[:display_name] = DisplayNameCache.get_display_name(reply['username'])
#         end
#       end
#       ret[:liked_sentence] = liked_sentence favorites
#       ret[:user_liked] = favorites.user_like(entry_id)
#     end
#     ret
#   end
#
#   def liked_sentence(favorites)
#     likes = []
#     likes << 'You' if favorites.user_like(entry_id)
#     if favorites.likes(entry_id)
#       likes += favorites.likes(entry_id)
#     else
#       other_likes = favorites.like_count(entry_id)
#       likes << "#{other_likes} people" if other_likes > 1
#       likes << '1 other person' if other_likes == 1
#     end
#     return case
#              when likes.count > 1
#                "#{likes[0..-2].join ', '} and #{likes.last} like this."
#              when likes.count > 0
#                if likes.first == 'You'
#                  'You like this.'
#                else
#                  "#{likes.first} likes this."
#                end
#            end
#   end
#
# end