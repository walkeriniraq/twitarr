Twitarr.PostsAllController = Twitarr.BasePostController.extend
  get_data_ajax: ->
    Twitarr.Post.all()
