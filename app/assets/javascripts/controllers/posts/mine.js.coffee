Twitarr.PostsMineController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.user @get('login_user'), info
