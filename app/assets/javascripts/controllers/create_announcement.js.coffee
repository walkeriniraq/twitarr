Twitarr.CreateAnnouncementController = Twitarr.ObjectController.extend
  text: ''
  errors: {}
  url_route: 'announcements'

  actions:
    send: ->
      errors = {}
      text = @get('text').trim()
      unless text
        errors = { text: 'Type something before clicking send!' }
      else
        Twitarr.BasePost.post('announcements', text).done (data) =>
          if data.status is 'ok'
            @set 'text', ''
            @transitionToRoute 'posts.feed'
          else
            alert(data.status)
      @set('errors', errors)

