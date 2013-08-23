Twitarr.PostsMineController = Twitarr.BasePostChildController.extend
  reload: ->
    Twitarr.Post.mine().done (data) =>
      Ember.run =>
        @set 'model', data

