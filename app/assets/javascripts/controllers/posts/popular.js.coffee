Twitarr.PostsPopularController = Twitarr.BasePostController.extend
  get_data_ajax: (info = null) ->
    Twitarr.Post.popular info

  checkNew: ->
    @load()

  load: ->
    @set 'loading', true
    @get_data_ajax().done((data) =>
      console.log(data.status) unless data.status is 'ok'
      Ember.run =>
        @set 'loading', false
        @set 'model', data
    ).fail(=>
      alert "There was a problem loading the posts from the server."
      @set 'loading', false
    )
