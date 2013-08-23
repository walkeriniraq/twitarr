Twitarr.PostsSearchController = Twitarr.BasePostController.extend
  tag: null

  get_data_ajax: ->
    Twitarr.Post.search(@get('tag'))
