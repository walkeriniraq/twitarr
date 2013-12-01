Twitarr.PostsAllController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.all info
