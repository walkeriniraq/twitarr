Twitarr.PostsNewController = Twitarr.Controller.extend
  text: ''
  errors: {}

  actions:
    send: ->
      errors = {}
      text = @get('text').trim()
      unless text
        errors = { text: 'Type something before clicking send!' }
      else
        Twitarr.Post.new(text).done (data) =>
          if data.status is 'ok'
            @set 'text', ''
            @transitionToRoute 'posts.feed'
          else
            alert(data.status)
      @set('errors', errors)
