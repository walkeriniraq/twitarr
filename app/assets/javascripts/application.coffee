#= require jquery
#= require jquery.ui.widget
#= require jquery.iframe-transport
#= require jquery.fileupload
#= require underscore
#= require moment

#= require angular
#= require angular-route
# require angular-animate
#= require angular-resource
#= require angular-sanitize
#= require angular-cookies
#= require angularLocalStorage

#= require_self
#= require twitarr
#= require router

window.console = { log: -> } unless window.console?

$.ajaxSetup
  beforeSend: (jqXHR) ->
    jqXHR.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))

@ie_browser = !!navigator.userAgent.match(/Trident\/\d+/)
@ff_browser = !!navigator.userAgent.match(/Firefox\/\d+/)

if (navigator.userAgent.match(/IEMobile\/10\.0/))
  msViewportStyle = document.createElement('style')
  msViewportStyle.appendChild(
    document.createTextNode(
      '@-ms-viewport{width:auto!important}'
    )
  )
  document.querySelector('head').appendChild(msViewportStyle)

@close_photo = ->
  $("#photo_modal").hide()
  $("#photo_modal #photo-holder img").attr("src", "")

String.prototype.capitalize = () -> return this.charAt(0).toUpperCase() + this.slice(1)

# These two functions are useful if we end up doing hashtag and username autocompletion
# (($, undefined_) ->
#   $.fn.getCursorPosition = ->
#     el = $(this).get(0)
#     pos = 0
#     if "selectionStart" of el
#       pos = el.selectionStart
#     else if "selection" of document
#       el.focus()
#       Sel = document.selection.createRange()
#       SelLength = document.selection.createRange().text.length
#       Sel.moveStart "character", -el.value.length
#       pos = Sel.text.length - SelLength
#     pos) jQuery

# These two functions are useful if we end up doing hashtag and username autocompletion
# (($, undefined_) ->
#   $.fn.setCursorPosition = (pos) ->
#     if @get(0).setSelectionRange
#       @get(0).setSelectionRange pos, pos
#     else if @get(0).createTextRange
#       range = @get(0).createTextRange()
#       range.collapse true
#       range.moveEnd "character", pos
#       range.moveStart "character", pos
#       range.select()) jQuery

#  LOG_TRANSITIONS: true
#  LOG_BINDINGS: true
  # ready: ->
  #   $("#app-loading").remove()

