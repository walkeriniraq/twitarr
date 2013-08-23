Twitarr.PostsPopularController = Twitarr.BasePostChildController.extend
  reload: ->
    Twitarr.Post.popular().done (data) =>
      Ember.run =>
        @set 'model', data

