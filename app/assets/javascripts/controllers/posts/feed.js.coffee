Twitarr.PostsFeedController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.feed info

  few_friends: (->
    @get('logged_in') && @get('friends').length < 5
  ).property('friends', 'logged_in')
