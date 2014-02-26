Twitarr.EntryDetailsController = Twitarr.ObjectController.extend Ember.TargetActionSupport,
  replying: false
  reply_pending: false

  actions:
    preview: (photo) ->
      if(window.innerWidth < 600 || window.innerHeight < 600)
        window.open "/photo/preview/#{photo.file}"
      else
        @send 'openModal', 'photo_view', photo

    reply: ->
      @set 'replying', not @get('replying')

    cancel_reply: ->
      @set 'replying', false

    favorite: (id) ->
      return if @get('model.user_liked')
      Twitarr.Post.favorite(id).done (data) =>
        return alert(data.status) unless data.status is 'ok'
        Ember.run =>
          @set 'model.user_liked', true
          @set 'model.liked_sentence', data.sentence

    make_post: ->
      if @get('reply_pending')
        alert "Reply currently being posted - please wait"
        return
      @set 'reply_pending', true
      text = @get 'text'
      return unless text.trim()

      Twitarr.Post.reply(text.trim(), @get('entry_id')).done (data) =>
        @set 'reply_pending', false
        return alert(data.status) unless data.status is 'ok'
        @get('replies').addObject(Twitarr.Reply.create(data.reply))
        @set 'text', ''
        @set 'replying', false

  entry_class: (->
    switch @get('type')
      when 'announcement' then 'announcement-entry'
      when 'post' then 'post-entry'
  ).property('type')

  liked_class: (->
    return 'glyphicon glyphicon-star' if @get('user_liked')
    'glyphicon glyphicon-star-empty'
  ).property('user_liked')

  can_delete: (->
    return false unless @get('logged_in')
    return true if @get('login_admin')
    @get('login_user') is @get('username')
  ).property('logged_in', 'login_user', 'login_admin')

  can_reply: (->
    @get('type') isnt 'announcement'
  ).property('type')

  can_like: (->
    @get('type') isnt 'announcement' and not @get('user_liked')
  ).property('user_liked', 'type')

  reply_template: (->
    'posts/create'
  ).property('type')
