Twitarr.SinglePhotoMixin = Ember.Mixin.create
  init: ->
    @set 'photo_id', null
    @set 'errors', Ember.A()

  photos: (->
    photo_id = @get('photo_id')
    if photo_id
      [ Twitarr.Photo.create { id: photo_id } ]
    else
      []
  ).property('photo_id')

  actions:
    file_uploaded: (data) ->
      if data.files[0]?.photo
        @set('photo_id', data.files[0].photo)
      else
        alert "Error: " + data.files[0]?.status

    remove_photo: ->
      @set 'photo_id', null

Twitarr.StreamViewController = Twitarr.ObjectController.extend Twitarr.SinglePhotoMixin,
  actions:
    show_new_post: ->
      @set 'new_post_visible', true

    cancel: ->
      @set 'new_post_visible', false

    new: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      return if @get('posting')
      @set 'posting', true
      Twitarr.StreamPost.reply(@get('id'), @get('reply_text'), @get('photo_id')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @set 'reply_text', @get('base_reply_text1')
          @set 'photo_id', null
          @send 'reload'
      , =>
        @set 'posting', false
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

Twitarr.StreamPageController = Twitarr.ObjectController.extend Twitarr.SinglePhotoMixin,
  new_post_visible: false

  new_post_button_visible: (->
    @get('logged_in') and not @get('new_post_visible')
  ).property('logged_in', 'new_post_visible')

  has_next_page: (->
    @get('next_page') isnt 0
  ).property('next_page')

  actions:
    show_new_post: ->
      @set 'new_post_visible', true

    cancel: ->
      @set 'new_post_visible', false

    new: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      return if @get('posting')
      @set 'posting', true
      Twitarr.StreamPost.new_post(@get('new_post'), @get('photo_id')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @set 'new_post', null
          @set 'photo_id', null
          @set 'new_post_visible', false
          @send 'reload'
      , =>
        @set 'posting', false
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

    next_page: ->
      return if @get('next_page') is 0
      @transitionToRoute 'stream.page', @get('next_page')

Twitarr.StreamPostPartialController = Twitarr.ObjectController.extend
  actions:
    like: ->
      @get('model').like()
    unlike: ->
      @get('model').unlike()
    view: ->
      @transitionTo 'stream.view', @get('id')

  unlike_visible: (->
    return 'hidden' unless @get('logged_in') and @get('user_likes')
    ''
  ).property('logged_in', 'user_likes')

  like_visible: (->
    return 'hidden' unless @get('logged_in') and not @get('user_likes')
    ''
  ).property('logged_in', 'user_likes')

Twitarr.StreamNewController = Twitarr.Controller.extend
  photo_id: null

  photos: (->
    photo_id = @get('photo_id')
    if photo_id
      [ Twitarr.Photo.create { id: photo_id } ]
    else
      []
  ).property('photo_id')

  actions:
    new: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      return if @get('posting')
      @set 'posting', true
      Twitarr.StreamPost.new_post(@get('new_post'), @get('photo_id')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @set 'new_post', ''
          @set 'photo_id', null
          @transitionToRoute 'stream'
      , ->
        @set 'posting', false
        alert 'Post could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

    file_uploaded: (data) ->
      if data.files[0]?.photo
        @set('photo_id', data.files[0].photo)
      else
        alert "Error: " + data.files[0]?.status

    remove_photo: ->
      @set 'photo_id', null