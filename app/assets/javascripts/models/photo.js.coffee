Twitarr.Photo = Ember.Object.extend
  id: null

  path: (->
    Twitarr.ApplicationController.sm_photo_path(@get('id'))
  ).property('id')