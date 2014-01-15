Twitarr.PhotoViewController = Ember.ObjectController.extend
  actions:
    close: ->
      @send('closeModal')

    open_full: ->
      window.open @get('full')