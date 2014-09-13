class StreamPost
  include Mongoid::Document

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  field :p, as: :photo, type: String

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  def validate_author
    return if author.blank?
    unless User.exist? author
      errors[:base] << "#{author} is not a valid username"
    end
  end

  def self.at_or_before(ms_since_epoch)
    where(:timestamp.lte => Time.at(ms_since_epoch.to_i / 1000))
  end

end