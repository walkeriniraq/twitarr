Twitarr.StreamPostPartialView = Ember.View.extend
  tagName: ''

  didInsertElement: ->
    @$('.body a').click (e) ->
      e.stopPropagation()
