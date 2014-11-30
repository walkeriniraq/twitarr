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
          @get('searchResults').pushObjects data.names
    ).observes('toInput')

  actions:
    cancel_autocomplete: ->
      @get('searchResults').clear()

    new: ->
      Ember.run =>
        return if @get('posting')
        @set 'posting', true
      users = @get('toUsers').filter((user) -> !!user)
      Twitarr.Seamail.new_seamail(users, @get('subject'), @get('text')).then((response) =>
        Ember.run =>
          @set 'posting', false
          if response.errors?
            @set 'errors', response.errors
            return
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
      Ember.run =>
        return if @get('posting')
        @set 'posting', true
      Twitarr.Seamail.new_message(@get('id'), @get('new_message')).then((response) =>
        Ember.run =>
          @set 'posting', false
          if response.errors?
            @set 'errors', response.errors
            return
          @set('new_message', '')
          @set 'errors', []
          window.history.go(-1)
      , ->
        @set 'posting', false
        alert 'Message could not be sent! Please try again later. Or try again someplace without so many seamonkeys.'
      )
    cancel: ->
      window.history.go(-1)


