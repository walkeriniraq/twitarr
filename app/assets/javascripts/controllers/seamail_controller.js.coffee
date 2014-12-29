Twitarr.SeamailIndexController = Twitarr.ArrayController.extend()

Twitarr.SeamailMetaPartialController = Twitarr.ObjectController.extend
  users_display: (->
    @get('display_names').join(', ')
  ).property('display_names')

Twitarr.SeamailNewController = Twitarr.Controller.extend
  searchResults: Ember.A()
  toUsers: Ember.A()
  errors: Ember.A()
  toInput: ''

  autoComplete_change: (->
    val = @get('toInput').trim()
    return if @last_search is val
    if !val
      @get('searchResults').clear()
      return
    @last_search = val
    $.getJSON("user/autocomplete?string=#{encodeURIComponent val}").then (data) =>
      if @last_search is val
        @get('searchResults').clear()
        names = (name for name in data.names when name not in @get('toUsers'))
        @get('searchResults').pushObjects names
  ).observes('toInput')

  actions:
    cancel_autocomplete: ->
      @get('searchResults').clear()

    new: ->
      return if @get('posting')
      @set 'posting', true
      users = @get('toUsers').filter((user) ->
        !!user)
      Twitarr.Seamail.new_seamail(users, @get('subject'), @get('text')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @get('errors').clear()
          @get('toUsers').clear()
          @set 'subject', ''
          @set 'text', ''
          window.history.go(-1)
      , ->
        @set 'posting', false
        alert 'Message could not be sent. Please try again later. Or try again someplace without so many seamonkeys.'
      )

    remove: (name) ->
      @get('toUsers').removeObject(name.toString())

    select: (name) ->
      @get('toUsers').addObject(name.toString())
      @set 'toInput', ''
      @get('searchResults').clear()
      @last_search = ''
      $('#to-autocomplete').focus()

Twitarr.SeamailNewMessageController = Twitarr.Controller.extend
  actions:
    new: ->
      return if @get('posting')
      @set 'posting', true
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'posting', false
          @set('new_message', '')
          @get('errors').clear()
          window.history.go(-1)
      , ->
        @set 'posting', false
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )
    cancel: ->
      window.history.go(-1)


