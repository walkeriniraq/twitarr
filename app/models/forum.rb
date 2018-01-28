class Forum
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia
  include Searchable

  field :sj, as: :subject, type: String
  field :lp, as: :last_post_time, type: Time

  embeds_many :posts, class_name: 'ForumPost', store_as: :fp, order: :timestamp.asc, validate: false

  index({:subject => 'text', :'fp.tx' => 'text'})
  # 1 = ASC, -1 DESC
  index 'fp.au' => 1
  index 'fp.lk' => 1
  index 'fp.ts' => -1

  validates :subject, presence: true
  validate :validate_posts

  def validate_posts
    errors[:base] << 'Must have a post' if posts.size < 1
    posts.each do |post|
      unless post.valid?
        post.errors.full_messages.each { |x| errors[:base] << x }
      end
    end
  end

  def subject=(subject)
    super subject.andand.strip
  end

  def last_post
    posts.last.timestamp
  end

  def post_count
    posts.size
  end

  def post_count_since(timestamp)
    posts.select { |x| x.ts > timestamp } .count
  end

  def created_by
    posts.first.author
  end

  def self.create_new_forum(author, subject, first_post_text, photos)
    forum = Forum.new subject: subject
    forum.last_post_time = Time.now
    forum.posts << ForumPost.new(author: author, text: first_post_text, timestamp: Time.now, photos: photos)
    if forum.valid?
      forum.save
    end
    forum
  end

  # This is just a terrible scheme
  def add_post(author, text, photos)
    self.last_post_time = Time.now
    posts.create author: author, text: text, timestamp: Time.now, photos: photos
  end

  def self.view_mentions(params = {})
    query_string = params[:query]
    start_loc = params[:page] || 0
    limit = params[:limit] || 20
    query = where(:'fp.mn' => query_string)
    if params[:after]
      query = query.gt(:'fp.ts' => params[:after])
    end
    query.order_by(timestamp: :desc).skip(start_loc*limit).limit(limit)
  end

  def self.search(params = {})
    search_text = params[:text].strip.downcase
    criteria = Forum.or({:'fp.au' => search_text}, { '$text' => { '$search' => "\"#{search_text}\"" } })
    limit_criteria(criteria, params)
  end
end
