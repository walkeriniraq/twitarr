class BaseDecorator < Draper::Decorator

  include Twitter::Autolink
  include CruiseMonkeyHelper

  @@emojiRE = Regexp.new('\:(buffet|die-ship|die|fez|hottub|joco|pirate|ship-front|ship|towel-monkey|tropical-drink|zombie)\:')
  @@emojiReplace = '<img src="/img/emoji/small/\1.png" class="emoji">'

  def clean_text(text)
    CGI.escapeHTML(text).gsub(@@emojiRE, @@emojiReplace)
  end

  def clean_text_with_cr(text)
    CGI.escapeHTML(text || '').gsub("\n", '<br />').gsub(@@emojiRE, @@emojiReplace)
  end

  def twitarr_auto_linker(text, options = {})
    if options[:app] == 'CM'
      cm_auto_link text, options
    elsif options[:app] == 'plain'
      # plain wants us to not do any markup
      text
    else
      auto_link text
    end
  end

end
