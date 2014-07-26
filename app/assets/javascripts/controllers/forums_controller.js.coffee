Twitarr.ForumsIndexController = Twitarr.ArrayController.extend()

Twitarr.ForumsDetailController = Twitarr.ObjectController.extend
  actions:
    new: ->
      Twitarr.Forum.new_post(@get('id'), @get('new_post')).then((data) =>
        @set('new_post', '')
        @get('posts').pushObject(Twitarr.ForumPost.create(data.forum_post))
      , ->
        alert 'post could not be saved!'
      )
#      post = @store.createRecord 'forum_post', {
#        author: @get('login_user')
#        text: @get('new_post')
#        timestamp: new Date()
#      }
