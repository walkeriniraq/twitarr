class StreamPost
  include Mongoid::Document

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  field :p, as: :photo, type: String
  field :lk, as: :likes, type: Array, default: []

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  # 1 = ASC, -1 DESC
  index :likes => 1
  index :timestamp => -1
  index :author => 1

  def validate_author
    return if author.blank?
    unless User.exist? author
      errors[:base] << "#{author} is not a valid username"
    end
  end

  def add_like(username)
    StreamPost.
        where(id: id).
        find_and_modify( {'$addToSet' => {lk: username} }, new: true)
  end

  def remove_like(username)
    StreamPost.
        where(id: id).
        find_and_modify( {'$pull' => {lk: username} }, new: true)
  end

  def self.at_or_before(ms_since_epoch, filter_author = nil)
    query = where(:timestamp.lte => Time.at(ms_since_epoch.to_i / 1000.0))
    query = query.where(:author => filter_author) if filter_author
    query
  end

  def self.at_or_after(ms_since_epoch, filter_author = nil)
    query = where(:timestamp.gte => Time.at(ms_since_epoch.to_i / 1000.0))
    query = query.where(:author => filter_author) if filter_author
    query
  end

end