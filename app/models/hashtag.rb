class Hashtag
  include Mongoid::Document

  MIN_AUTO_COMPLETE_LEN = 3
  LIMIT = 10

  field :_id, type: String, as: :name

  def self.add_tag(hashtag)
    begin
      hashtag = hashtag[1..-1] if hashtag[0] == '#'
      hashtag = hashtag.downcase
      hashtag.strip!
      doc = Hashtag.new(name:hashtag)
      doc.upsert
      doc
    rescue Exception => e
      logger.error e
    end
  end

  def self.auto_complete(prefix)
    unless prefix and prefix.size >= MIN_AUTO_COMPLETE_LEN
      puts "#{prefix} is not large enough"
      return nil
    end
    prefix = prefix[1..-1] if prefix[0] == '#'
    prefix = prefix.downcase
    Hashtag.where(name: /^#{prefix}/).asc(:name).limit(LIMIT)
  end

  # this is probably not going to be a fast operation
  def self.repopulate_hashtags
    StreamPost.distinct(:hash_tags).each do |ht|
      Hashtag.add_tag ht
    end
  end
end