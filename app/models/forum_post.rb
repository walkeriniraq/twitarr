class ForumPost
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Searchable
  include Postable

  # Common fields between stream_post and forum_post
  field :au, as: :author, type: String
  field :tx, as: :text, type: String
  field :ts, as: :timestamp, type: Time
  field :lk, as: :likes, type: Array, default: []
  field :ht, as: :hash_tags, type: Array
  field :mn, as: :mentions, type: Array
  field :et, as: :entities, type: Array

  field :ph, as: :photos, type: Array
  embedded_in :forum, inverse_of: :posts

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  before_validation :parse_hash_tags
  after_create :post_create_operations

  def photos
    self.photos = [] if super.nil?
    super
  end

end
