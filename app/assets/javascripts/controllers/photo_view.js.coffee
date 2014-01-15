Twitarr.PhotoViewController = Ember.ObjectController.extend
  actions:
    close: ->
      @send('closeModal')
