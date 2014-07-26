Twitarr.ForumsIndexController = Twitarr.ArrayController.extend()

Twitarr.ForumsDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      post = @store.createRecord 'forum_post', {
        author: @get('login_user')
        text: @get('new_post')
        timestamp: new Date()
      }
      post.save().then(=>
        @set('new_post', '')
      , ->
        alert 'post could not be saved!'
      )