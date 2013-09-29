Twitarr.Message = Ember.Object.extend
  message_to: null
  subject: null
  text: null

  validate: ->
    errors = {}
    errors.message_to = 'Please specify a recipient.' unless @get('message_to')
    errors.text = 'Cannot send an empty message.' unless @get('text')
    errors

  to_json: ->
    {
      message_to: @get('message_to')
      subject: @get('subject')
      text: @get('text')
    }