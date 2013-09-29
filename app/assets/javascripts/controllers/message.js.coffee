Twitarr.MessageController = Twitarr.ObjectController.extend

  actions:
    send: ->
      @set('errors', {})
      errors = @get('model').validate()
      if _.keys(errors).length
        @set('errors', errors)
        return
      $.ajax(type: 'PUT', url: 'user/message', data: { message: @get('model').to_json() }).done (data) ->
        unless data.status is 'ok'
          alert data.status