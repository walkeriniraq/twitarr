Twitarr.EventsPageController = Twitarr.ObjectController.extend
#  has_next_page: (->
#    @get('has_next_page')
#  ).property('has_next_page')

  has_prev_page: (->
    @get('page') > 0
  ).property('page')

  actions:
    next_page: ->
      @transitionToRoute 'events.page', @get('page') + 1
    prev_page: ->
      @transitionToRoute 'events.page', @get('page') - 1
    create_event: ->
      @transitionToRoute 'events.new'
    csv: ->
      window.location.replace("/api/v2/event/csv")

Twitarr.EventsPastController = Twitarr.ObjectController.extend
  has_next_page: (->
    @get('next_page') isnt null and @get('next_page') isnt undefined
  ).property('next_page')

  has_prev_page: (->
    @get('prev_page') isnt null and @get('prev_page') isnt undefined
  ).property('prev_page')

  actions:
    next_page: ->
      return if @get('next_page') isnt null and @get('next_page') isnt undefined
      @transitionToRoute 'events.past', @get('next_page')
    prev_page: ->
      return if @get('prev_page') isnt null and @get('prev_page') isnt undefined
      @transitionToRoute 'events.past', @get('prev_page')

Twitarr.EventsMetaPartialController = Twitarr.ObjectController.extend()

Twitarr.EventsDetailController = Twitarr.ObjectController.extend
  editable: (->
    @get('logged_in') and (@get('author') is @get('login_user') or @get('login_admin'))
  ).property('logged_in', 'author', 'login_user', 'login_admin')

  signed_up: (->
    !$.inArray(@get('login_user'), @get('signups'))
  ).property('author', 'signups')

  can_sign_up: (->
    return false if !@get('max_signups')
    return true if $.inArray(@get('login_user'), @get('signups')) # Let people unsign-up
    @get('signups').length <= @get('max_signups')
  ).property('signups', 'max_signups', 'login_user')

  favourited: (->
    !$.inArray(@get('login_user'), @get('favorites'))
  ).property('favorites', 'login_user')

  actions:
    signup: ->
      @get('model').signup()
    unsignup: ->
      @get('model').unsignup()
    favourite: ->
      @get('model').favourite()
    unfavourite: ->
      @get('model').unfavourite()
    edit: ->
      @transitionToRoute 'events.edit', @get('id')
    delete: ->
      if(confirm("Are you sure you want to delete this event?"))
        r=@get('model').delete()
        @transitionToRoute 'events.page', 0 if r
    ical: ->
      window.location.replace("/api/v2/event/#{@get('id')}/ical")

Twitarr.EventsNewController = Twitarr.Controller.extend
  init: ->
    @set 'errors', Ember.A()

  start_time: (->
    getUsableTimeValue()
  ).property()

  actions:
    new: ->
      return if @get('posting')
      @set 'posting', true
      Twitarr.Event.new_event(@get('title'), @get('description'), @get('location'), @get('start_time'), @get('end_time')).then((response) =>
        if response.errors?
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @set 'title', ''
          @set 'description', ''
          @set 'location', ''
          @set 'start_time', getUsableTimeValue()
          @set 'end_time', ''
          @set 'max_signups', ''

          @set 'posting', false
          @get('errors').clear()
          @transitionToRoute 'events.page', 0
      , ->
        @set 'posting', false
        alert 'Event could not be added. Please try again later. Or try again someplace without so many seamonkeys.'
      )

Twitarr.EventsEditController = Twitarr.ObjectController.extend
  errors: Ember.A()

  actions:
    save: ->
      return if @get('posting')
      @set 'posting', true
      Twitarr.Event.edit(@get('id'), @get('description'), @get('location'), @get('start_time'), @get('end_time')).then((response) =>
        if response.status isnt 'ok'
          @set 'errors', response.errors
          @set 'posting', false
          return
        Ember.run =>
          @get('errors').clear()
          @set 'posting', false
          @transitionToRoute 'events.detail', @get('id')
      , ->
        @set 'posting', false
        alert 'Event could not be saved! Please try again later. Or try again someplace without so many seamonkeys.'
      )

Twitarr.EventsAllController = Twitarr.ObjectController.extend
  has_next_page: (->
    @get('next_page') isnt null and @get('next_page') isnt undefined
  ).property('next_page')

  has_prev_page: (->
    @get('prev_page') isnt null and @get('prev_page') isnt undefined
  ).property('prev_page')

  actions:
    next_page: ->
      return if @get('next_page') isnt null and @get('next_page') isnt undefined
      @transitionToRoute 'events.own', @get('next_page')
    prev_page: ->
      return if @get('prev_page') isnt null and @get('prev_page') isnt undefined
      @transitionToRoute 'events.own', @get('prev_page')
    csv: ->
      window.location.replace("/api/v2/event/csv?source=own")


getUsableTimeValue = -> d = new Date(); d.toISOString().replace('Z', '').replace(/:\d{2}\.\d{3}/, '')