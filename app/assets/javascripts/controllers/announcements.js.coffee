Twitarr.AnnouncementsController = Twitarr.ObjectController.extend
  url_route: 'announcements'

  can_delete: (->
    @get('is_admin')
  ).property('is_admin')

  make_post: ->
    text = @get 'newPost'
    return unless text.trim()

    Twitarr.Message.post(@url_route, text).done (data) =>
      if data.status is 'ok'
        @reload()
    @set 'newPost', ''

  delete: (post_id) ->
    Twitarr.Message.delete(@url_route, post_id).done (data) =>
      if data.status is 'ok'
        @reload()

  reload: ->
    Twitarr.Message.list(@url_route).then (message) =>
      Ember.run =>
        @set 'model', message

