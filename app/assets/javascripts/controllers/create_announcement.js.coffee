Twitarr.CreateAnnouncementController = Twitarr.ObjectController.extend
  text: ''
  offset: 1
  errors: {}
  url_route: 'announcements'

  actions:
    send: ->
      errors = {}
      text = @get('text').trim()
      unless text
        errors = { text: 'Type something before clicking send!' }
      else
        $.post("announcements/submit", { message: text, offset: @get('offset') }).done (data) =>
          if data.status is 'ok'
            @set 'text', ''
            @transitionToRoute 'posts.feed'
          else
            alert(data.status)
      @set('errors', errors)

