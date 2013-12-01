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
      info = { direction: 'before', time: @get('model.posts.lastObject.time') }
      @get_data_ajax(info).done((data) =>
        console.log(data.status) unless data.status is 'ok'
        Ember.run =>
          @set 'loading', false
          if data.posts
            @get('model.posts').addObject(post) for post in data.posts
          else
            @set 'canLoadMore', false
      ).fail(=>
        alert "There was a problem loading the posts from the server."
        @set 'loading', false
      )
