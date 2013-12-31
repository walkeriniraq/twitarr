Twitarr.PostsFeedController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.feed info
