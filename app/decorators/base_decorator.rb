class BaseDecorator < Draper::Decorator

  def clean_text(text)
    CGI.escapeHTML(text)
  end

  def clean_text_with_cr(text)
    CGI.escapeHTML(text).gsub("\n", '<br />')
  end

end