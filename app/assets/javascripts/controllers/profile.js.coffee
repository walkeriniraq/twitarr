Twitarr.ProfileController = Twitarr.Controller.extend
  errors: []
  needs: 'application'

  actions:
    save: ->
      display_name = @get('display_name').trim()
      $.post("user/profile", { display_name: display_name }).done (data) =>
        if data.status isnt 'ok'
          alert data.status
        else
          @set('controllers.application.display_name', display_name)
