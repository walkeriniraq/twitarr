module PostTagsTrait
  def tags
    tags = (%W(@#{username}) + message.scan(/[@#]\w+/)).map { |x| x.downcase }.uniq.select { |x| x.length > 2 }
    tags.select { |x| x.start_with? '@' }.each { |x| tags << x.sub('@', '#') }
    tags
  end
end