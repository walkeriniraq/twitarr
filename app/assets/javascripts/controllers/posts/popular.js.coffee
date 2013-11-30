Twitarr.PostsPopularController = Twitarr.BasePostController.extend
  canLoadMore: true

  get_data_ajax: (info = null) ->
    Twitarr.Post.popular(info)

  showMore: (->
    @.get('canLoadMore') && !@get('loading')
  ).property('canLoadMore', 'loading')

  actions:
    loadMore: ->
      return if @get('loading')
      @set 'loading', true
      info = { direction: 'before', time: @get('last') }
      @get_data_ajax(info).done((data) =>
        console.log(data.status) unless data.status is 'ok'
        Ember.run =>
          @set 'loading', false
          @get('model.posts').addObject(post) for post in data.posts
          @set 'model.last', data.last
      ).fail(=>
        alert "There was a problem loading the posts from the server."
        @set 'loading', false
      )
