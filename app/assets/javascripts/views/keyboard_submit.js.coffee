Twitarr.StreamViewView = Ember.View.extend
  keyDown: (e) ->
    @get('controller').send('new') if e.ctrlKey and e.keyCode == 13

Twitarr.StreamPageView = Ember.View.extend
  keyDown: (e) ->
    @get('controller').send('new') if e.ctrlKey and e.keyCode == 13

Twitarr.StreamEditView = Ember.View.extend
  keyDown: (e) ->
    @get('controller').send('save') if e.ctrlKey and e.keyCode == 13

Twitarr.SeamailDetailView = Ember.View.extend
  keyDown: (e) ->
    @get('controller').send('post') if e.ctrlKey and e.keyCode == 13

Twitarr.ForumsNewView = Ember.View.extend
  keyDown: (e) ->
    @get('controller').send('new') if e.ctrlKey and e.keyCode == 13