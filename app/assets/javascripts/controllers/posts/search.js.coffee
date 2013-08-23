Twitarr.PostsSearchController = Twitarr.BasePostChildController.extend
  tag: null
  reload: ->
    Twitarr.Post.search(@get('tag')).done (data) =>
      Ember.run =>
        @set 'model', data

