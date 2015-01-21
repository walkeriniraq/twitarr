Twitarr.ForumsDetailView = Ember.View.extend
  keyDown: (e) ->
    @get('controller').send('new') if e.ctrlKey and e.keyCode == 13

  setupScrollToOutlet: (->
    Ember.run.scheduleOnce('afterRender', @, =>
      # this compensates for the height of the top bar
      position = @$('.scroll_to').offset().top - 60
      window.scrollTo(0, position)
    )
  ).on('didInsertElement')
