Twitarr.PostsMineController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.mine info
