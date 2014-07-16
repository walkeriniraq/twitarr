Twitarr.BaseSeamailController = Twitarr.ObjectController.extend
  loading: false

  actions:
    reload: ->
      @reload()

  reload: ->
    @set 'loading', true
    @get_data_ajax().done((data) =>
      console.log(data.status) unless data.status is 'ok'
      Ember.run =>
        @set 'loading', false
        @set 'model', data
      @after_reload() if @after_reload
    ).fail( =>
      alert "There was a problem loading the posts from the server."
      @set 'loading', false
    )
