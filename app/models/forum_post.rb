class ForumPost
  include Mongoid::Document

  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  field :ph, as: :photos, type: Array
  field :lk, as: :likes, type: Array, default: []

  embedded_in :forum, inverse_of: :posts

  # 1 = ASC, -1 DESC
  index :likes => 1
  index :timestamp => -1

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  def validate_author
    return if author.blank?
    unless User.exist? author
      errors[:base] << "#{author} is not a valid username"
    end
  end

  def add_like(username)
    ForumPost.
        where(id: id).
        find_and_modify( {'$addToSet' => {lk: username} }, new: true)
  end

  def remove_like(username)
    ForumPost.
        where(id: id).
        find_and_modify( {'$pull' => {lk: username} }, new: true)
  end

  def author=(username)
    super User.format_username username
  end

  def photos
    self.photos = [] if super.nil?
    super
  end

end