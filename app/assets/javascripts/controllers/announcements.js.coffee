Twitarr.AnnouncementsController = Twitarr.ObjectController.extend
  url_route: 'announcements'

  can_delete: (->
    @get('login_admin')
  ).property('login_admin')

  actions:
    make_post: ->
      text = @get 'newPost'
      return unless text.trim()

      Twitarr.BasePost.post(@url_route, text).done (data) =>
        if data.status is 'ok'
          @reload()
      @set 'newPost', ''

    delete: (post_id) ->
      Twitarr.BasePost.delete(@url_route, post_id).done (data) =>
        if data.status is 'ok'
          @reload()

  reload: ->
    Twitarr.BasePost.list(@url_route).then (message) =>
      Ember.run =>
        @set 'model', message

