Twitarr.SeamailNewController = Twitarr.ObjectController.extend

  actions:
    send: ->
      @set('errors', {})
      errors = @get('model').validate()
      if _.keys(errors).length
        @set('errors', errors)
        return
      @get('model').post().done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @transitionToRoute 'posts.feed'
