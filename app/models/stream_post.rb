# noinspection RubyStringKeysInHashInspection
class StreamPost
  include Mongoid::Document
  include Twitter::Extractor
  include Postable

  field :p, as: :photo, type: String
  field :pc, as: :parent_chain, type: Array, default: []

  validates :text, :author, :timestamp, presence: true
  validate :validate_author

  # 1 = ASC, -1 DESC
  index likes: 1
  index timestamp: -1
  index author: 1
  index mentions: 1
  index hash_tags: 1
  index parent_chain: 1
  index text: 'text'

  before_validation :parse_hash_tags
  after_create :post_create_operations


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

  def parent_chain
    self.parent_chain = [] if super.nil?
    super
  end

end