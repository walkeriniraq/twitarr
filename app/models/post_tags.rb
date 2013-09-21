module PostTags
  def tags
    (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }
  end
end