Ember.Handlebars.helper 'dynPartial', (name, options) ->
  Ember.Handlebars.helpers.partial.apply(@, arguments)

window.Twitarr = Ember.Application.create(
  LOG_TRANSITIONS: true
  LOG_BINDINGS: true
)

$.ajaxSetup
  beforeSend: (jqXHR) ->
    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
