Twitarr.PostsFeedController = Twitarr.BasePostController.extend
  get_data_ajax: ->
    Twitarr.Post.feed()
  few_friends: (->
    @get('logged_in') && @get('friends').length < 5
  ).property('friends', 'logged_in')
