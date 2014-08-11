Twitarr.SeamailNewController = Twitarr.ObjectController.extend
  searchResults: []
  toPeople: []
  toInput: ''
  subject: ''
  text: ''
  errors: ''

  autoComplete_change: (->
    val = @get('toInput').trim()
    return if @last_search is val
    if !val
      @set 'searchResults', []
      return
    @last_search = val
    $.getJSON("user/autocomplete?string=#{encodeURIComponent val}").then (data) =>
      if @last_search is val
        @set 'searchResults', data.names
  ).observes('toInput')

  actions:
    remove: (name) ->
      @toPeople.removeObject(name.toString())

    select: (name) ->
      @toPeople.addObject(name.toString())
      @set 'toInput', ''
      @set 'searchResults', []
      @last_search = ''
      $('#to-autocomplete').focus()

    send: ->
      seamail = Twitarr.Seamail.create subject: @get('subject'), text: @get('text')
      val = @get('toInput')
      if !!val
        @toPeople.addObject val.toString()
      seamail.to = @get('toPeople').join(' ')
      @set('errors', {})
      errors = seamail.validate()
      if _.keys(errors).length
        @set('errors', errors)
        return
      seamail.post().done (data) =>
        unless data.status is 'ok'
          alert data.status
        else
          @set 'searchResults', []
          @set 'toPeople', []
          @last_search = ''
          @set 'toInput', ''
          @set 'subject', ''
          @set 'text', ''
          @transitionToRoute 'seamail.inbox'
