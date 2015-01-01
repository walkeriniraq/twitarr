class ForumPost
  include Mongoid::Document
  include Postable

  field :ph, as: :photos, type: Array
  embedded_in :forum, inverse_of: :posts

  # 1 = ASC, -1 DESC
  index :likes => 1
  index :timestamp => -1

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  before_validation :parse_hash_tags
  after_create :post_create_operations

  def photos
    self.photos = [] if super.nil?
    super
  end

end