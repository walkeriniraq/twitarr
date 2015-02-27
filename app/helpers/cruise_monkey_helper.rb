module CruiseMonkeyHelper
  include Twitter::Autolink

  def cm_auto_link(text, options = {})
    auto_link text, CRUISE_MONKEY_OPTIONS
  end

  #private
  def self.prepare_cruise_monkey_link(entity, attributes)
    puts entity
    if entity[:hashtag]
      attributes.delete :href
      attributes['ng-click'] = "openTag('#{entity[:hashtag]}')"
    elsif entity[:screen_name]
      attributes.delete :href
      attributes['ng-click'] = "openUser('#{entity[:screen_name]}')"
    elsif entity[:url]
      attributes.delete :href
      attributes['ng-click'] = "openUrl('#{entity[:url]}', '_blank')"
    end
  end

  CRUISE_MONKEY_OPTIONS = {
      link_attribute_block: lambda{|entity, attributes| prepare_cruise_monkey_link(entity, attributes)},
      username_include_symbol: false,
  }
end
