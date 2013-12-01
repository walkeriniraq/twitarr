Twitarr.BasePostController = Twitarr.ObjectController.extend
  loading: false
  canLoadMore: true

  showMore: (->
    @.get('canLoadMore') && !@get('loading')
  ).property('canLoadMore', 'loading')

  actions:
    delete: (id) ->
      Twitarr.Post.delete(id).done (data) =>
        return alert(data.status) unless data.status is 'ok'
        posts = _(@get('posts')).reject (x) ->
          x.post_id is id
        @set 'posts', posts
    reload: ->
      @reload()

    loadMore: ->
      return if @get('loading')
      @set 'loading', true
      info = { direction: 'before', time: @get('model.posts.lastObject.time') }
      @get_data_ajax(info).done((data) =>
        console.log(data.status) unless data.status is 'ok'
        Ember.run =>
          @set 'loading', false
          if data.posts.length
            @get('model.posts').addObject(post) for post in data.posts
          else
            @set 'canLoadMore', false
      ).fail(=>
        alert "There was a problem loading the posts from the server."
        @set 'loading', false
      )

  reload: ->
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
