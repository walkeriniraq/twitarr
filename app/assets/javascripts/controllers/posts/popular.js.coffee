Twitarr.PostsPopularController = Twitarr.BasePostChildController.extend
  get_data_ajax: ->
    Twitarr.Post.popular()
