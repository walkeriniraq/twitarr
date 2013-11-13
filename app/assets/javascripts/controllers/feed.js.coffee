Twitarr.FeedController = Twitarr.ArrayController.extend
  few_friends: (->
    @get('friends').length < 5
  ).property('friends')
