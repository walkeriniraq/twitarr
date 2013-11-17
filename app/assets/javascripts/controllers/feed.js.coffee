Twitarr.FeedController = Twitarr.ArrayController.extend
  few_friends: (->
    @get('logged_in') && @get('friends').length < 5
  ).property('friends', 'logged_in')
