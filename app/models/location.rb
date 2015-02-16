class Location
  include Mongoid::Document

  MIN_AUTO_COMPLETE_LEN = 3
  LIMIT = 10

  field :_id, type: String, as: :name

  def self.add_location(location)
    begin
      doc = Location.new(name:location)
      doc.upsert
      doc
    rescue Exception => e
      logger.error e
    end
  end
  def self.valid_location?(location)
    (location.nil? || location.empty?) || Location.where(name: location).exists?
  end

  def self.auto_complete(prefix)
    unless prefix and prefix.size >= MIN_AUTO_COMPLETE_LEN
      return nil
    end
    prefix = prefix.downcase
    Location.where(name: /^#{prefix}/i).asc(:name).limit(LIMIT)
  end
end