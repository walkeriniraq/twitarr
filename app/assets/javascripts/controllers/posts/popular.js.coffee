Twitarr.PostsPopularController = Twitarr.BasePostController.extend
  get_data_ajax: ->
    Twitarr.Post.popular()
