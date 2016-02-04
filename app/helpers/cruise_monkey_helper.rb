module CruiseMonkeyHelper
  include Twitter::Autolink

  def cm_auto_link(text, options = {})
    auto_link text, CRUISE_MONKEY_OPTIONS
  end

  #private
  def self.prepare_cruise_monkey_link(entity, attributes)
    puts entity
    attributes.delete :href
    attributes.delete :class
    attributes.delete :title
    if entity[:hashtag]
      attributes['cm-hashtag'] = "#{entity[:hashtag]}"
    elsif entity[:screen_name]
      attributes['cm-user'] = "#{entity[:screen_name]}"
    elsif entity[:url]
      attributes['cm-link'] = "#{entity[:url]}"
    end
  end

  CRUISE_MONKEY_OPTIONS = {
      link_attribute_block: lambda{|entity, attributes| prepare_cruise_monkey_link(entity, attributes)},
      username_include_symbol: false,
  }
end
