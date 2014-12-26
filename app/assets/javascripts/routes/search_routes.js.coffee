Twitarr.SearchRoute = Ember.Route.extend
  actions:
    search: (text) ->
      $.getJSON("search/#{text}").done (data) =>
        if data.status is 'ok'
          console.log data.results