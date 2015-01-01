Twitarr.StreamPostPartialView = Ember.View.extend
  didInsertElement: ->
    @$('.body a').click (e) ->
      e.stopPropagation()
