Twitarr.ParsedTextView = Ember.View.extend
  templateName: 'parsed_text'
  tagName: 'span'

  parsed_message: (->
    @process_message(@get('content')).replace(new RegExp('\n', 'gm'), '<br/>')
  ).property 'content'

  process_message: (message)->
    msg = ''
    msg += @process_part(part) for part in message.split /([@#][\w&-]+)/
    msg

  process_part: (part) ->
    switch part[0]
      when '@'
        "<a href='#/posts/user/#{part.substring 1}'>#{part}</a>"
      when '#'
        "<a href='#/posts/tag/#{part.substring 1}'>#{part}</a>"
      else
        part

