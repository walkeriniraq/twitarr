window.Twitarr = Ember.Application.create()

Twitarr.Router.map ->
  @resource 'announcements', { path: '/' }

Twitarr.AnnouncementsRoute = Ember.Route.extend
  model: ->
    Twitarr.Announcements.find()

Twitarr.Announcements = DS.Model.extend
  message: DS.attr 'string'
  username: DS.attr 'string'
  post_time: DS.attr 'string'

Twitarr.Store = DS.Store.extend
  revision: 12
  adapter: 'DS.FixtureAdapter'

Twitarr.Announcements.FIXTURES = [
    id: 1
    message: 'foo'
    username: 'bar'
    post_time: '1373332876'
  ,
    id: 2
    message: 'foo2'
    username: 'bar2'
    post_time: '1373339876'
  ]

Twitarr.AnnouncementController = Ember.ObjectController.extend
  isEditing: false

  editAnnouncement: ->
    @set 'isEditing', true

Twitarr.AnnouncementsController = Ember.ArrayController.extend
  createAnnouncement: ->
    text = @get 'newPost'
    return unless text.trim()

    announcement = Twitarr.Announcements.createRecord
      message: text
      username: 'kvort'
      post_time: '1373333176'

    @set 'newPost', ''

    announcement.save()