# noinspection RubyStringKeysInHashInspection
class StreamPost
  include Mongoid::Document
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
  field :ed, as: :edits, type: Array, default: []
  field :lc, as: :location, type: String

  field :p, as: :photo, type: String
  field :pc, as: :parent_chain, type: Array, default: []

  validates :text, :author, :timestamp, presence: true
  validate :validate_author
  validate :validate_location

  # 1 = ASC, -1 DESC
  index likes: 1
  index timestamp: -1
  index author: 1
  index mentions: 1
  index hash_tags: 1
  index parent_chain: 1
  index text: 'text'

  before_validation :parse_hash_tags
  before_save :post_create_operations


  def self.at_or_before(ms_since_epoch, options = {})
    query = where(:timestamp.lte => Time.at(ms_since_epoch.to_i / 1000.0))
    query = query.where(:author.in => options[:filter_authors]) if options.has_key? :filter_authors
    query = query.where(author: options[:filter_author]) if options.has_key? :filter_author
    query
  end

  def self.at_or_after(ms_since_epoch, options = {})
    query = where(:timestamp.gte => Time.at(ms_since_epoch.to_i / 1000.0))
    query = query.where(:author.in => options[:filter_authors]) if options.has_key? :filter_authors
    query = query.where(author: options[:filter_author]) if options.has_key? :filter_author
    query
  end

  def destroy_parent_chain
    self.parent_chain = []
    save
  end

  def parent_chain
    self.parent_chain = [] if super.nil?
    super
  end

  def self.search(params = {})
    search_text = params[:text].strip.downcase.gsub(/[^0-9A-Za-z_\s@]/, '')
    criteria = StreamPost.or({ author: /^#{search_text}/ }, { '$text' => { '$search' => "\"#{search_text}\"" } })
    limit_criteria(criteria, params).order_by(timestamp: :desc)
  end
end