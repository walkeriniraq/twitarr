## Code in this class was adapted from jquery.tagcloud: http://github.com/addywaddy/jquery.tagcloud.js
##
## Copyright (c) 2008 Adam Groves
##
## Permission is hereby granted, free of charge, to any person obtaining
## a copy of this software and associated documentation files (the
## "Software"), to deal in the Software without restriction, including
## without limitation the rights to use, copy, modify, merge, publish,
## distribute, sublicense, and/or sell copies of the Software, and to
## permit persons to whom the Software is furnished to do so, subject to
## the following conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
## OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
## WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#Twitarr.Tags = Ember.ArrayProxy.create
#  content: []
#
#  FONT_RANGE: 12
#  COLOR_RANGE: { start: "#00F", end: "#F00" }
#
#  colorIncrement: (color, range) ->
#    jQuery.map @toRGB(color.end), (n, i) =>
#      (n - @toRGB(color.start)[i]) / range
#
#  toRGB: (code) ->
#    if (code.length is 4)
#      code = code.replace(/(\w)(\w)(\w)/gi, "\$1\$1\$2\$2\$3\$3")
#    hex = /(\w{2})(\w{2})(\w{2})/.exec(code)
#    [parseInt(hex[1], 16), parseInt(hex[2], 16), parseInt(hex[3], 16)]
#
#  tagColor: (color, increment, weighting) ->
#    rgb = jQuery.map(@toRGB(color.start), (n, i) ->
#      ref = Math.round(n + (increment[i] * weighting))
#      if (ref > 255)
#        ref = 255
#      else
#        if (ref < 0)
#          ref = 0
#      ref)
#    @toHex(rgb)
#
#  toHex: (ary) ->
#    "#" + jQuery.map(ary, (i) ->
#      hex =  i.toString(16)
#      if (hex.length is 1) then "0" + hex else hex
#    ).join("");
#
#  reload: ->
#    $.getJSON('/posts/tag_cloud').then (data) =>
#      Ember.run =>
#        return unless data.tags?
#        @clear()
#        @pushObject(Twitarr.Tag.create(tag)) for tag in data.tags
#        max = @reduce((max, tag_obj) ->
#          return tag_obj.count if tag_obj.count > max
#          max
#        , 0)
#        min = @reduce((min, tag_obj) ->
#          return tag_obj.count if tag_obj.count < min
#          min
#        , 1000)
#        range = max - min
#        range = 1 if range < 1
#        fontIncr = @FONT_RANGE / range
#        colorIncr = @colorIncrement(@COLOR_RANGE, range)
#        @forEach (tag_obj) =>
#          weighting = tag_obj.count - min
#          tag_obj.size = "#{12 + (weighting * fontIncr)}px"
#          tag_obj.color = @tagColor(@COLOR_RANGE, colorIncr, weighting)
#          true
#
#Twitarr.Tag = Ember.Object.extend()
