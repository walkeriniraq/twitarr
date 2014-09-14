class Forum
  include Mongoid::Document

  field :sj, as: :subject, type: String

  embeds_many :posts, class_name: 'ForumPost', store_as: :fp, order: :timestamp.desc, validate: false

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
    self[:subject] = subject.andand.strip
  end

  def last_post
    posts.first.timestamp
  end

  def post_count
    posts.size
  end

  def self.create_new_forum(author, subject, first_post_text, photos)
    forum = Forum.new subject: subject
    forum.posts << ForumPost.new(author: author, text: first_post_text, timestamp: Time.now, photos: photos)
    if forum.valid?
      forum.save
    end
    forum
  end

  def add_post(author, text, photos)
    posts.create author: author, text: text, timestamp: Time.now, photos: photos
  end

end