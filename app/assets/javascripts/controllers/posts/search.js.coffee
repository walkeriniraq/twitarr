Twitarr.PostsSearchController = Twitarr.BasePostController.extend
  tag: null

  get_data_ajax: (info = null) ->
    Twitarr.Post.search(@get('tag'), info)
