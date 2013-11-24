module PostTagsTrait
  def tags
    tags = (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }
    tags
  end
end