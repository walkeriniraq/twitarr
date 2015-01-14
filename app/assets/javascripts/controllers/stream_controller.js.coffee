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
  init: ->
    @set 'parent_link_visible', true

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
          @get('errors').clear()
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
          @get('errors').clear()
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
      @transitionToRoute 'stream.view', @get('id')
    edit: ->
      @transitionToRoute 'stream.edit', @get('id')
    view_parent: ->
      [..., p] = @get('parent_chain')
      @transitionToRoute 'stream.view', p

  show_parent: (->
      @get('parentController').get('parent_link_visible') && @get('parent_chain')
  ).property('parent_chain', 'new_post_visible')

  editable: (->
    @get('logged_in') and (@get('author') is @get('login_user') or @get('login_admin'))
  ).property('logged_in', 'author', 'login_user', 'login_admin')

  unlikeable: (->
    @get('logged_in') and @get('user_likes')
  ).property('logged_in', 'user_likes')

  likeable: (->
    @get('logged_in') and not @get('user_likes')
  ).property('logged_in', 'user_likes')

Twitarr.StreamEditController = Twitarr.ObjectController.extend
  errors: Ember.A()

  photos: (->
    photo_id = @get('photo_id')
    if photo_id
      [ Twitarr.Photo.create { id: photo_id } ]
    else
      []
  ).property('photo_id')

  actions:
    save: ->
      if @get('controllers.application.uploads_pending')
        alert('Please wait for uploads to finish.')
        return
      return if @get('posting')
      @set 'posting', true
      Twitarr.StreamPost.edit(@get('id'), @get('text'), @get('photo_id')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @get('errors').clear()
          @set 'posting', false
          @transitionToRoute 'stream.view', @get('id')
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