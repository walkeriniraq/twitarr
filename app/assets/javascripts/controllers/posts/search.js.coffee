Twitarr.PostsSearchController = Twitarr.BasePostChildController.extend
  tag: null

  get_data_ajax: ->
    Twitarr.Post.search(@get('tag'))
