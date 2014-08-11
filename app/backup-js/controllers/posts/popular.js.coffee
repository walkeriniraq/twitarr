Twitarr.PostsPopularController = Twitarr.BasePostController.extend
  last_tags_load: null
  tags: Twitarr.Tags

  get_data_ajax: (info = null) ->
    Twitarr.Post.popular info

  load: ->
    @_super()
    hour_ago = new Date(Date.now() - 3600000)
    if hour_ago > @last_tags_load
      @last_tags_load = new Date()
      Twitarr.Tags.reload()
