Twitarr.PostsPopularController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.popular info
