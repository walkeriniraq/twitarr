Twitarr.BaseSeamailController = Twitarr.ObjectController.extend
  loading: false

  actions:
    reload: ->
      @reload()

  get_data_ajax: ->
    Twitarr.Seamail.archive()

  reload: ->
    @set 'loading', true
    @get_data_ajax().done((data) =>
      console.log(data.status) unless data.status is 'ok'
      Ember.run =>
        @set 'loading', false
        @set 'model', data
    ).fail( =>
      alert "There was a problem loading the posts from the server."
      @set 'loading', false
    )
