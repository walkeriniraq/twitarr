class Announcement
  include Mongoid::Document

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  field :vu, as: :valid_until, type: Time

  index valid_until: -1

  def self.valid_announcements
    where(:valid_until.gt => Time.now)
  end

end
